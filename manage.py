import os
import sys
import subprocess
import hashlib
def get_cwd():
	return os.path.dirname(os.path.normpath(__file__))

postgresql = {
	"version": "42.6.0",
	"hash": "b817c67a40c94249fd59d4e686e3327ed0d3d3fae426b20da0f1e75652cfc461",
	"url": "https://jdbc.postgresql.org/download/postgresql-42.6.0.jar",
	"size": 1081604
}
def install(cwd, url, hash, size, path):
	tmpfile = os.path.join(cwd, "build/downloads/%s.tmp" % (hash,))
	downloaded = 0
	try:
		downloaded = os.path.getsize(tmpfile)
		if downloaded == size:
			hashlib
	except OSError as error:
		pass
	if downloaded == size:
		
	return tmpfile
	download_result = subprocess.run(["curl", "-o", tmpfile, url])
	print(download_result)
def main():
	sysargs = sys.argv[1:]
	abs_cwd = get_cwd()
	rel_cwd = os.path.relpath(abs_cwd)
	if sysargs[0] == "install":
		install(rel_cwd, postgresql["url"], postgresql["hash"], postgresql["size"], "")

main()