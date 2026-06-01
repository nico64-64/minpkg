#! /bin/bash

# install.sh
# Script d'installation de minpkg.
# Exécutez ce script pour créer les dossiers nécessaires au fonctionnement de minpkg et placer minpkg lui-même au bon endroit.


INSTALL_PATH=/usr/bin
PKGS_PATH=/usr/pkgs
DEFAULT_PREFIX=/usr
INSTALL_KRNLUPD=y
SYS_CONF_DIR=/etc


# Prise en charge des arguments (options):
for arg in "$@"
do
	case $arg in
	--help | --aide | -h | -a | '-?')
		echo "=== install.sh ==="
		echo "Script d'installation de minpkg."
		echo ""
		echo "Vous n'êtes pas obligé d'utiliser ce script, mais il vous facilitera certainement la vie."
		echo ""
		echo "Voici les options que peut accepter ce script:"
		echo -e "--help (-h / -?)\tAffiche ce texte"
		echo -e "--default-prefix=...\tIndique l'endroit où seront créés la plupart des symlinks"
		echo -e "\t\t\t(valeur par défaut: /usr)"
		echo -e "--install-path=...\tIndique l'endroit où installer minpkg"
		echo -e "\t\t\t(valeur par défaut: /usr/bin)"
		echo -e "--pkgs-path=...\t\tIndique l'endroit où seront installés les packages"
		echo -e "\t\t\t(valeur par défaut: /usr/pkgs)"
		echo -e "--sysconfdir=...\tIndique l'endroit où seront placés les fichiers de"
		echo -e "\t\t\tconfiguration de minpkg (valeur par défaut: /etc)"
		echo -e "--verbose (-v)\t\tAffiche plus d'informations sur les actions effectuées"
		echo -e "\t\t\tpar ce script"
		echo -e "--without-krnlupd\tN'installe pas krnlupd, l'outil de mise à jour du kernel"
		echo -e "\t\t\tde minpkg"
		echo ""
		exit
		;;

	--default-prefix=*)
		DEFAULT_PREFIX="${arg#*=}"
		;;

	--install-path=*)
		INSTALL_PATH="${arg#*=}"
		;;

	--pkgs-path=* | --packages-path=*)
		PKGS_PATH="${arg#*=}"
		;;

	--sysconfdir=*)
		SYS_CONF_DIR="${arg#*=}"
		;;

	--verbose | -v)
		VERBOSE='-v'
		;;

	--without-krnlupd)
		INSTALL_KRNLUPD=n
		;;

	*)
		echo -e "\e[31mErreur!\e[0m Cette option ($arg) n'est pas supportée."
		exit
		;;
	esac
done

# Sommes-nous root?
if [ $(id -u) -ne 0 ]
then
	echo "Svp exécuter ce script en tant que root."
	exit
fi

echo -e "\n\e[1m\e[32m=== Installation de minpkg ===\e[0m\n"
echo -e "\e[1mminpkg\e[0m sera installé sur ce système avec les options reçues en arguments par ce script."
echo -e "Entrez $0 --help pour en connaître la liste."
echo -e "\nConfirmez-vous l'installation? (y/n)"
read input
case "$input" in
oui | yes | o | y)
	;;
*)
	echo -e "\e[31mInstallation annulée.\e[0m"
	exit
	;;
esac
echo ""

# Vérifications:
if ! [ -f minpkg ]
then
	echo -e "\e[31mErreur!\e[0m Fichier \"minpkg\" introuvable."
	echo "veuillez lancer ce script depuis le dossier source."
	exit
fi
if [ $INSTALL_KRNLUPD == y ] && ! [ -f krnlupd ]
then
	echo -e "\e[31mErreur!\e[0m Fichier \"krnlupd\" introuvable."
	echo "Veuillez lancer ce script depuis le dossier source."
	exit
fi
echo "Vérification de la présence de bash (dépendance)..."
if ! [ -f /bin/bash ]
then
	echo -e "\e[31mErreur!\e[0m"
	echo -e "Veuillez installer bash sur votre système."
	echo -e "Il est fort probable que zsh fonctionne aussi, mais ce n'est pas testé."
	echo -e "Une simple shell POSIX comme dash ou ash ne sera pas suffisant."
	exit
fi
for dependance in {sed,install,find}
do
	echo "Vérification de la présence de $dependance (dépendance)..."
	if ! [ $(command -v install) ] || ! [ $(command -v sed) ]
	then
		echo -e "\e[31mErreur!\e[0m"
		echo "Veuillez installer $dependance sur votre système."
		echo "Référez-vous au README.md pour plus d'informations."
		exit
	fi
done
echo "Vérification de l'existence de $INSTALL_PATH (dossier d'installation)..."
if ! [ -d "$INSTALL_PATH" ]
then
	echo -e "\e[31mErreur!\e[0m"
	echo "Veuillez spécifier un dossier d'installation valide."
	exit
fi
for outil in {tar,unzip,make,cmake,meson,ninja,pip3,grep,sudo}
do
	echo "Vérification de la présence de $outil..."
	if ! [ $(command -v $outil) ]
	then
		echo -e "\e[93mAttention!\e[0m Il semble que $outil ne soit pas installé sur votre système."
		echo "minpkg n'en a pas strictement besoin, mais cela limitera les fonctionnalités disponibles."
		echo "COnsultez le README.md pour plus de détails."
	fi
done
echo -e "\nDébut de l'installation...\n"

# Installation de krnlupd:
if [ $INSTALL_KRNLUPD == y ]
then
	# Création du dossier de configuration:
	install $VERBOSE -dm755 $SYS_CONF_DIR/minpkg/krnlupd
	if [ $SYS_CONF_DIR != /etc ]
	then
		sed -i "s|/etc|$SYS_CONF_DIR|g" krnlupd
	fi

	# Installation de krnlupd lui-même:
	install $VERBOSE -m755 krnlupd "$INSTALL_PATH"

	# Nettoyage de minpkg:
	sed -i "s/#KRNLUPD_HOOK_END//" minpkg
	sed -i "s/#KRNLUPD_HOOK//" minpkg
elif [ $INSTALL_MINPKG == y ]
then
	# Corrections à minpkg si krnlupd n'est pas installé:
	sed -i "/#KRNLUPD_HOOK/,/#KRNLUPD_HOOK_END/d" minpkg
fi

# Installation globale:
# Création du dossier d'installation des packages:
install $VERBOSE -dm755 $PKGS_PATH

# Corrections:
if [ $PKGS_PATH != /usr/pkgs ]
then
	sed -i "s|/usr/pkgs|$PKGS_PATH|g" minpkg
fi
if [ $DEFAULT_PREFIX != /usr ]
then
	sed -i "s|--prefix=/usr|--prefix=$DEFAULT_PREFIX|g" minpkg
fi

# Installation de minpkg lui-même:
install $VERBOSE -m755 minpkg "$INSTALL_PATH"

# Installation terminée!
echo "Installation terminée!"
echo "Si vous n'avez pas reçu aucun message d'erreur durant l'installation,"
echo "  vous pouvez supprimer ce répertoire."
