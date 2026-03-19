#! /bin/bash

# install.sh
# Script d'installation de minpkg.
# Exécutez ce script pour créer les dossiers nécessaires au fonctionnement de minpkg et placer minpkg lui-même au bon endroit.


INSTALL_PATH=/usr/bin
CREATE_ROOT_CACHE_DIR=y
PKGS_PATH=/usr/pkgs
INSTALL_MINPKG=y
DEFAULT_PREFIX=/usr


# Sommes-nous root?
if [ $(id -u) -eq 0 ]
then
	echo "N'exécutez pas ce script en tant que root!"
	exit
fi

# Prise en charge des arguments (options):
for arg in "$@"
do
	case $arg in
	--help | --aide | -h | -a | '-?')
		echo "=== install.sh ==="
		echo "Script d'installation de minpkg."
		echo ""
		echo "Vous n'êtes pas obligé d'utiliser ce script, mais il vous facilitera la vie."
		echo ""
		echo "Voici les options que peut accepter ce script:"
		echo -e "--help (-h / -?)\tAffiche ce texte"
		echo -e "--default-prefix=...\tIndique l'endroit où seront créés la plupart des"
		echo -e "\t\t\tsymlinks (valeur par défaut: /usr)"
		echo -e "--install-path=...\tIndique l'endroit où installer minpkg"
		echo -e "\t\t\t(valeur par défaut: /usr/bin)"
		echo -e "--pkgs-path=...\t\tIndique l'endroit où seront installés les packages"
		echo -e "\t\t\t(valeur par défaut: /usr/pkgs)"
		echo -e "--verbose (-v)\t\tAffiche plus d'informations sur les actions effectuées"
		echo -e "\t\t\tpar ce script"
		echo -e "--without-installing\tCrée les dossiers de cache pour l'utilisateur,"
		echo -e "\t\t\tmais n'installe pas minpkg"
		echo -e "--without-root-cache\tNe crée pas de dossier de cache pour l'utilisateur root"
		echo ""
		exit
		;;

	--default-prefix=*)
		DEFAULT_PREFIX="${arg#*=}"
		;;

	--install-path=*)
		INSTALL_PATH="${arg#*=}"
		;;

	--pkgs-path=* | --packages-path)
		PKGS_PATH="${arg#*=}"
		;;

	--verbose | -v)
		VERBOSE='-v'
		;;

	--without-installing)
		INSTALL_MINPKG=n
		;;

	--without-root-cache)
		CREATE_ROOT_CACHE_DIR=n
		;;

	*)
		echo -e "\e[31mErreur!\e[0m Cette option ($arg) n'est pas supportée."
		exit
		;;
	esac
done

echo -e "\n\e[1m\e[32m=== Installation de minpkg ===\e[0m\n"
echo -e "\e[1mminpkg\e[0m sera installé sur ce système avec les options reçues en arguments par ce script."
echo -e "Entrez $0 --help pour en connaître la liste."
echo -e "\nConfirmez-vous l'installation? (y/n)"
read input
case input in
oui | yes | o | y)
	;;
*)
	echo -e "\e[31mInstallation annulée.\e[0m"
	exit
	;;
esac
echo ""

# Vérifications:
if [ $INSTALL_MINPKG == y ]
then
	if ! [ -f minpkg ]
	then
		echo -e "\e[31mErreur!\e[0m Fichier \"minpkg\" introuvable."
		echo "veuillez lancer ce script depuis le même dossier que ce fichier."
		exit
	fi
	echo "Vérification de la présence de bash (dépendance)..."
	if ! [ -f /bin/bash ]
	then
		echo -e "\e[31mErreur!\e[0m"
		exit
	fi
	echo "Vérification de la présence de install et sudo (outils de construction)..."
	if ! [ $(command -v install) ] || ! [ $(command -v sudo) ]
	then
		echo -e "\e[31mErreur!\e[0m"
		exit
	fi
	echo "Vérification de l'existence de $INSTALL_PATH (dossier d'installation)..."
	if ! [ -d "$INSTALL_PATH" ]
	then
		echo -e "\e[31mErreur!\e[0m"
		exit
	fi
	for outil in {make,cmake,meson,ninja,pip3}
	do
		echo "Vérification de la présence de $outil..."
		if ! [ $(command -v $outil) ]
		then
			echo -e "\e[93mAttention!\e[0m Il semble que $outil ne soit pas installé sur votre système."
			echo "Installez-le pour pouvoir utiliser pleinement minpkg."
		fi
	done
	echo -e "\nDébut de l'installation...\n"
fi

# Création des dossiers par utilisateur:
mkdir $VERBOSE -p ~/.cache/minpkg/{sandbox,sources}
if [ $CREATE_ROOT_CACHE_DIR == y ] && [ $INSTALL_MINPKG == y ]
then
	sudo mkdir $VERBOSE -p /root/.cache/minpkg/{sandbox,sources}
fi

# Installation globale:
if [ $INSTALL_MINPKG == y ]
then
	# Création du dossier d'installation des packages:
	sudo mkdir $VERBOSE -p $PKGS_PATH
	if [ $PKGS_PATH != /usr/pkgs ]
	then
		sed -i "s|/usr/pkgs|$PKGS_PATH|g" minpkg
	fi

	# Corrections:
	if [ $DEFAULT_PREFIX != /usr ]
	then
		sed -i "s|--prefix=/usr|--prefix=$DEFAULT_PREFIX|g" minpkg
	fi

	# Installation de minpkg lui-même:
	sudo install $VERBOSE -m755 minpkg "$INSTALL_PATH"
fi

# Installation terminée!
echo "Installation terminée!"
echo "Si vous n'avez pas reçu aucun message d'erreur durant l'installation,"
echo "  vous pouvez supprimer ce répertoire."
echo "Toutefois, si vous prévoyez que d'autres utilisateurs utiliseront minpkg pour"
echo "  installer des packages, chacun d'entre eux devrait lancer ce script avec"
echo "  --without-installing afin de générer leur dossier de cache personnel."
