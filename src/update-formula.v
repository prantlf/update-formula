import crypto.sha256 { hexhash }
import os { create, read_lines }
import prantlf.cli { Cli, Env, run }
import prantlf.debug { new_debug }
import prantlf.github { download_asset, get_gh_token, get_latest_release }
import prantlf.pcre { pcre_compile }

const d = new_debug('updtap')

const version = '0.1.4'

const usage = 'Updates version numbers and SHA-256 hashes in Homebrew formula files for GitHub releases.

Usage: update-formula [options] [<file> ...]

  <file>        formula file to update

Options:
  -d|--dry-run  only print what would be done without doing it
  -V|--version  print the version of the executable and exit
  -h|--help     print the usage information and exit

Examples:
  $ update-formula yaml2json.rb'

struct Opts {
	dry_run bool
mut:
	gh_token string
}

const re_home = pcre_compile('homepage "https://github.com/(.+)"', 0) or { panic('re_homepage') }
const re_ver = pcre_compile(r'version "((?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[.0-9A-Za-z-]+)?)"',
	0) or { panic('re_version') }
const re_url = pcre_compile('url "https://github.com/.+/releases/download/v([^/]+)/(.+)"',
	0) or { panic('re_url') }
const re_hash = pcre_compile('sha256 "(.+)"', 0) or { panic('re_hash') }
const re_tag = pcre_compile(r'"tag_name"\s*:\s*"v((?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[.0-9A-Za-z-]+)?)"',
	0) or { panic('re_tag') }

fn get_latest(repo string, token string) !string {
	body := get_latest_release(repo, token)!
	if body.len == 0 {
		return error('no release found in ${repo}')
	}
	if m := re_tag.exec(body, 0) {
		return m.group_text(body, 1) or { panic('') }
	}
	return error('no tag found in ${repo}/releases/latest')
}

fn get_hash(url string, token string) !string {
	body := download_asset(url, token)!
	return hexhash(body)
}

fn update(file string, opts &Opts) ! {
	println('file: ${file}')

	d.log('reading "%s"', file)
	mut lines := read_lines(file)!

	d.log_str('parsing contents')
	mut repo := ''
	mut new_ver := ''
	mut url := ''
	for i, line in lines {
		if m := re_home.exec(line, 0) {
			repo = m.group_text(line, 1) or { panic('') }
			println('  repository: "${repo}"')
		} else if m := re_ver.exec(line, 0) {
			if repo.len == 0 {
				return error('version spotted before homepage')
			}
			ver := m.group_text(line, 1) or { panic('') }
			new_ver = get_latest(repo, opts.gh_token)!
			if ver == new_ver {
				println('  version ${ver} is already the latest')
				return
			}
			println('  updating version ${ver} to ${new_ver}')
			start, end := m.group_bounds(1) or { panic('') }
			lines[i] = line[..start] + new_ver + line[end..]
		} else if m := re_url.exec(line, 0) {
			if new_ver.len == 0 {
				return error('url spotted before version')
			}
			asset := m.group_text(line, 2) or { panic('') }
			println('  asset: "${asset}"')
			url = 'https://github.com/${repo}/releases/download/v${new_ver}/${asset}'
			start, end := m.group_bounds(1) or { panic('') }
			lines[i] = line[..start] + new_ver + line[end..]
			continue
		} else if m := re_hash.exec(line, 0) {
			if url.len == 0 {
				return error('hash not preceded with url')
			}
			hash := get_hash(url, opts.gh_token)!
			println('  hash: "${hash}"')
			start, end := m.group_bounds(1) or { panic('') }
			lines[i] = line[..start] + hash + line[end..]
		}
		url = ''
	}

	if opts.dry_run {
		d.log_str('  not writing (dry-run)')
		return
	}

	d.log_str('reopening the file')
	mut out := create(file)!
	defer {
		out.close()
	}

	d.log_str('writing new contents')
	for line in lines {
		out.writeln(line)!
	}
	out.close()
	d.log_str('file written')
}

fn body(mut opts Opts, args []string) ! {
	if args.len == 0 {
		return error('missing file')
	}

	if opts.gh_token.len == 0 {
		opts.gh_token = get_gh_token()!
	}

	for arg in args {
		update(arg, opts)!
	}
}

fn main() {
	run(Cli{
		usage: usage
		version: version
		env: Env.both
	}, body)
}
