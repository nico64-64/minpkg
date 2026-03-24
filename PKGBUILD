# Exemple de PKGBUILD supporté par minconvert

# Maintainer: Your Name <youremail@domain.com>

# Nom (minpkg):
pkgname= # name

# Version (minpkg):
pkgver= # version
pkgrel= # release (can have multiple release per version)

# Description (minpkg):
pkgdesc="" # description
url="" # project homepage
license=() #license(s)

# Dépendances (minconvert):
depends=() # required at runtime
makedepends=() # requiered at build
checkdepends=() # requiered to test
optdepends=() # optionnal dependencies
provides=() # virtual packages provided
conflicts=() # packages which can't be installed at the same time
replaces=() # obsoletes packages replaced by this one

# Sources (minconvert):
source=("$pkgname-$pkgver.tar.gz" "$pkgname-$pkgver.patch") # source files required (url or local files)
noextract=() # the files in 'source' shouldn't be extracted

# Setté par minconvert:
# srcdir = directory where sources are extracted
# pkgdir = directory where package is built (root of the package)
# startdir = directory where the PKGBUILD is


prepare()
{
# exécuté automatiquement par minconvert tout de suite après l'extraction
# /!\ exécuté même s'il n'y a pas eu d'extraction, contrairement à ce que makepkg fait
	cd "$srcdir/$pkgname-$pkgver"
	patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
}


# Fonctions seddées par minconvert afin de déterminer si une commande minpkg peut être formée:

build()
{
# manual configuration and build commands
	cd "$pkgname-$pkgver"
	./configure --prefix=/usr
	make
}


check()
{
# called to run the tests of the package
	cd "$pkgname-$pkgver"
	make -k check
}


package()
{
# installs the package in $pkgdir (typically with DESTDIR)
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}
