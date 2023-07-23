import os
import urllib.request
import hashlib
import sys
import sqlite3 as sqlite
class CorruptedDownload(Exception):
	def __init__(self, header):
		Exception.__init__(self)
		self.where_header = header

class ConflictSize(Exception):
	def __init__(self, header):
		Exception.__init__(self)
		self.where_header = header
class ConflictHash(Exception):
	def __init__(self, header):
		Exception.__init__(self)
		self.where_header = header
class HeaderNotFound(Exception):
	def __init__(self, url):
		Exception.__init__(self)
		self.where_url = url

def create_directory(path, journal):
	try:
		os.mkdir(path)
	except FileExistsError as error:
		journal.append((error, path))
def log_mkdir(journal):
	for _, path in journal:
		print("[DEBUG] path '%s' already exists!" % (path,), file=sys.stderr)
def filesize_where(path):
	try:
		return os.path.getsize(path)
	except OSError:
		return 0 
FROM_CACHE = 1
CREATED = 0
NOT_FOUND = 2
class LazyFetch:
	def __init__(self, factory, url, status,header=None):
		self.url = url
		self.status = status
		self.factory = factory
		self.header = header
	def with_params(self, size, filehash):
		factory = self.factory
		if self.status != NOT_FOUND:
			return factory.apply_target(self.header)
		header = FileHeader(self.url, size, filehash)
		if not factory.has_file(header):
			factory.force_download(header).install()
		factory.add_header(header)
		return factory.apply_target(header)
	def __repr__(self):
		return "(%s,%s)" % (repr(self.url), repr(self.header))
class Downloaded:
	def __init__(self, origin, destination, header):
		self.origin = origin
		self.destination = destination
		self.header = header
	def install(self):
		os.mkdir(self.destination)
		filename = os.path.join(self.destination, "file.bin")
		lockname = os.path.join(self.destination, "lock.txt")
		os.rename(self.origin, filename)
		with open(lockname, 'x') as lockfile:
			print(self.header.filehash)
			lockfile.write(self.header.filehash)
class FileHeader:
	def __init__(self, url, size, filehash, urlhash=None, name=None):
		self.url = url
		self.size = size
		self.urlhash = urlhash
		self.filehash = filehash
		self.name = name
	@staticmethod
	def hash(url):
		return hashlib.sha256(url.encode()).hexdigest()
	def getid(self):
		if self.urlhash == None:
			self.urlhash = FileHeader.hash(self.url)
		return self.urlhash
	def getname(self):
		if self.name == None:
			self.name = "%s.bin" % (self.urlhash,)
		return self.name
	def __repr__(self):
		data = (repr(self.url), self.size, self.filehash)
		return "(%s,%d,%s)" % data
class DownloadedHeader:
	def __init__(self, header, target):
		self.header = header
		self.target = target
class Downloader:
	def __init__(self, root_dir="~/.dynimport/"):
		self.root = os.path.normpath(os.path.expanduser(root_dir))
		self.cache = os.path.join(self.root, "cache")
		self.downloads = os.path.join(self.root, "downloads")
		self.headers = os.path.join(self.root, "urls.db")
		#print(self.headers)
		self.database = None
	def getdb(self):
		if self.database == None:
			self.opendb()
		return self.database
	def opendb(self):
		self.database = sqlite.connect(self.headers)
	def create_root(self, debug=False, journal=None):
		if journal == None:
			journal = []
		create_directory(self.root, journal)
		create_directory(self.downloads, journal)
		create_directory(self.cache, journal)
		if debug:
			log_mkdir(journal)
		query =  "CREATE TABLE IF NOT EXISTS urls"
		query += "(urlhash BLOB PRIMARY KEY, url TEXT, size INT, filehash TEXT);"
		self.getdb().execute(query).close()
	def add_header(self, header):
		urlhash = header.getid()
		url = header.url
		size = header.size
		filehash = header.filehash
		query = "INSERT INTO urls VALUES (?,?,?,?)"
		cursor = self.getdb().execute(query, (urlhash, url, size, filehash))
		result = cursor.fetchone()
		cursor.close()
		self.database.commit()
	def get_header(self, url):
		urlhash = FileHeader.hash(url) 
		query =	"SELECT * FROM urls WHERE urlhash = ?" 
		result = self.getdb().execute(query, (urlhash,)).fetchone()
		if result == None:
			raise HeaderNotFound(url)
		return FileHeader(result[1], result[2], result[3], result[0])
	def force_download(self, header):
		filename = header.getname()
		download = os.path.join(self.downloads, filename)
		cache = os.path.join(self.cache, header.getid())
		print("[DEGUG] downloading %s", (repr(header),)) 
		urllib.request.urlretrieve(header.url, download)
		size = filesize_where(download)
		if size != header.size:
			raise CorruptedDownload(header)
		with open(download, "rb") as source:
			digest = hashlib.file_digest(source, "sha256").hexdigest()
		if digest != header.filehash:
			print(digest)
			raise CorruptedDownload(header)
		return Downloaded(download, cache, header)
	def has_file(self, header):
		target = os.path.join(self.cache, header.getid())
		filename = os.path.join(target, "file.bin")
		lockname = os.path.join(target, "lock.txt")
		size = filesize_where(filename)
		if size:
			if size != header.size:
				raise ConflictSize(header)
			with open(lockname, "r") as lockfile:
				localhash = lockfile.read()
			if localhash != header.filehash:
				raise ConflictHash(header)
			return True
		return False
	def apply_target(self, header):
		return DownloadedHeader(header, self.get_target(header))
	def get_target(self, header):
		return os.path.join(self.cache, header.getid())
	def download(self, header):
		if self.has_file(header):
			return FROM_CACHE
		self.force_download(header).install()
		return CREATED
	def lazyfetch(self, url):
		try:
			header = self.get_header(url)
			status = self.download(header)
			return LazyFetch(self, url, status, header)
		except HeaderNotFound:
			return LazyFetch(self, url, NOT_FOUND)
		