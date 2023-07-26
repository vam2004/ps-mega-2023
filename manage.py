import os
import downloader as dependencies
import shutil
import sys
def get_cwd():
	return os.path.dirname(os.path.normpath(__file__))

postgresql = {
	"version": "42.6.0",
	"hash": "b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461",
	"url": "https://jdbc.postgresql.org/download/postgresql-42.6.0.jar",
	"size": 1081604,
	"path": ".libs/postgresql-42.6.0.jar"
}
def download(downloader, cwd, url, size, filehash, path):
	copyto = os.path.join(cwd, path)	
	try:
		open(copyto, "x").close()
	except FileExistsError:
		pass
	header = downloader.lazyfetch(url).with_params(size, filehash)
	filename = os.path.join(header.target, "file.bin")
	print("copying %s into %s" % (repr(filename), repr(copyto)))
	shutil.copy2(filename, copyto)
def usage():
	pass
def reinstall(rel_cwd, downloader):
	psql_url, psql_size = postgresql["url"], postgresql["size"]
	psql_hash, psql_path = postgresql["hash"], postgresql["path"]
	download(downloader, rel_cwd, psql_url, psql_size, psql_hash, psql_path)
def install(rel_cwd, downloader, debug=False):
	journal = []
	dependencies.create_directory(".libs", journal)
	dependencies.create_directory(".build", journal)
	downloader.create_root(debug, journal)
	reinstall(rel_cwd, downloader)
def get_or_default(array, index, otherwise = None):
	if index < len(array):
		return array[index]
	else:
		return otherwise

def main():
	sysargs = sys.argv[1:]
	abs_cwd = get_cwd()
	rel_cwd = os.path.relpath(abs_cwd)
	if len(sysargs) == 0:
		return usage()
	if sysargs[0] == "reinstall":
		root_dir = get_or_default(sysargs, 1, "~/.dynimport")
		reinstall(rel_cwd, dependencies.Downloader(root_dir))
	if sysargs[0] == "install":
		root_dir = get_or_default(sysargs, 1, "~/.dynimport")
		install(rel_cwd, dependencies.Downloader(root_dir), debug=True)
	if sysargs[0] == "build":
		pass
	
main()
