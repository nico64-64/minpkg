# MINPKG

***a MINimal PacKaGe manager***<br>
Un package manager minimal.

## Description
minpkg n'est pas un package manager comme les autres. Ce n'est en fait à la base qu'un script bash servant de wrapper autour des différents systèmes de construction des packages.

Les principales différences avec un package manager normal sont que:
- minpkg utilise le code source des packages (et non leurs binaires précompilés)
- minpkg fonctionne en local seulement (vous devez télécharger vous-même les sources des packages que vous voulez installer)
- minpkg offre plus de contrôle sur la configuration des packages (vous devez par contre savoir comment construire vos packages)
- minpkg est facile à comprendre de A à Z
- minpkg permet de conserver plusieurs versions d'un même package

Les principales différences par rapport à la compilation manuelle sont que:
- l'installation se fait en une seule commande (au lieu des 3 traditionnelles)
- il est très facile de savoir quels fichiers ont été installés par quel package
- il est très facile de savoir quels packages ont été installés et comment, quand, par qui, etc.

En date de la version 1.6.4, minpkg supporte les systèmes suivants:
- Décompression: tar, zip
- Configuration: autoconf (`./configure`), cmake, meson
- Construction: make, ninja, pip3
- Test: make, ninja
- Installation: make, ninja, pip3

(*) Les packages installés avec pip3 ne sont pas gérés par minpkg.

## Installation

### Dépendances:
En plus de coreutils et util-linux, vous aurez besoin des programmes suivant:
- bash (zsh fonctionnerait probablement aussi, mais ce n'est pas testé)
- sed
- install (compatible BSD)
- find

Les programmes suivants ne sont pas strictement nécessaire, mais apportent des fontionnalités parfois essentielles:
- tar (avec gzip, bz2, xz, etc.) (pour décompresser les sources)
- unzip (pour décompresser les sources)
- cmake (pour configurer les packages)
- meson (pour configurer les packages)
- make (pour construire et installer les packages, ainsi que mettre à jour le kernel)
- ninja (pour construire et installer les packages)
- pip3 (pour construire et installer des packages avec pip3)
- grep (pour la commande find de minpkg)
- sudo (pour utiliser minpkg en tant qu'usager normal)
- un éditeur de texte (pour la commande describe de minpkg)

### Installation standard:
Clonez ce repo avec git, puis lancez l'installation de minpkg en exécutant simplement le script fourni:
```bash
git clone https://github.com/nico64-64/minpkg.git
cd minpkg
./install.sh
```
Si vous ne recevez aucune erreur, vous pouvez ensuite supprimer les fichiers téléchargés. En cas d'erreur, essayez de faire une installation personnalisée.

**Note:** Un `Attention!`(jaune) n'est pas une `Erreur!`(rouge)! Vous pouvez ignorer les premiers sans problème.

### Installation personnalisée:
Lancez le script d'installation avec la commande `./install.sh --help` pour obtenir la liste des options acceptées.<br>
Les options les plus utiles et sont expliquées ici:

`--default-prefix=...`: minpkg utilise l'option `--prefix=...` lors de la configuration des packages. Par défaut, ce préfixe est /usr, mais vous pouvez le changer ici (par exemple en spécifiant `--prefix=/usr/local` si vous ne voulez pas mélanger les packages installés par minpkg avec ceux installés par votre package manager système).

`--pkgs-path=...`: Cette option permet de changer l'endroit où sont réellement installés les packages.<br>
Il n'y a pas vraiment de raison de changer la valeur par défaut (/usr/pkgs).

Une fois que vous avez trouvé quelles options doivent être utilisées, lancez le script d'installation avec elles.<br>
Si vous n'avez pas reçu d'erreur, vous pouvez ensuite supprimer les fichiers téléchargés si vous le voulez.

## Usage

### Installer un package
L'installation d'un package se fait avec la commande `minpkg install` (ou `minpkg +`) suivie du nom de l'archive (ou du dossier) contenant le package.

Par défaut, minpkg tentera de déterminer automatiquement le type d'archive, puis configurera le package en exécutant `./configure` (avec plusieurs options supplémentaires). minpkg construira ensuite le package avec `make` puis l'installera avec la commande automatiquement déterminée grâce au système de construction (donc `make install`, dans ce cas-ci).

Toutes ces commandes peuvent être remplacée par un autre système supporté avec les options `--archiver` (`-a`), `--config` (`-c`), `--build` (`-b`) et `--install` (`-i`). Les tests du package ne sont pas exécutés par défaut, mais ils peuvent l'être si vous spécifiez le système à utiliser via `--test` (`-t`). Vous pouvez en apprendre plus sur ces 5 options en démarrant minpkg avec les options `--config-help`, `--build-help`, etc.

Vous pouvez aussi conserver une copie des sources dans le dossier de cache de minpkg avec l'option `--keep-source` (`-K`).

Par défaut, minpkg ne conserve qu'une seule version de chaque package installé. Vous pouvez utiliser l'option `--keep-old` (`-k`) pour changer cela.

#### En cas de problème...
Par défaut, minpkg créera aussi un nouveau dossier nommé "build" à l'intérieur des sources du package. Le package sera construit depuis ce dossier. Plusieurs packages recommandent de les construire ainsi, mais cela peut poser problème avec d'autres. Dans un tel cas, vous pouvez désactiver cette fonctionnalité avec `--no-build-dir` (`-n`).

Par défaut, minpkg tente aussi d'enlever les symboles de débogage, mais cela ne fonctionne pas toujours. Si vous recevez une erreur de type "no target for 'install-strip'", installez le package avec `--no-strip`.

Il peut parfois être utile de décompresser soi-même le package puis de lui appliquer des modifications (comme une patch) avant de l'installer avec minpkg. Dans ce cas, si le package utilise autoconf pour se configurer, il est fort probable que la construction avec minpkg échoue avec une erreur de type "aclocal not found". Cela est causé par le fait que minpkg copie d'abord les sources avant de les utiliser. Cela réinitialise les timestamps des fichiers, et autoconf juge donc qu'il doit regénérer ces fichiers, et cela nécessite une certaine version d'autoconf qui n'est pas celle que vous avez installée. Par contre, ces fichiers n'ont souvent pas réellement besoin d'être regénérés. minpkg fournit donc une option (`--fix-aclocal`) qui ajuste les timestamps des fichiers nécessaires pour contenter autoconf.

Vous pouvez aussi construire vos packages sans les installer pour d'abord vérifier si minpkg est bien capable de les construire. Utilisez pour cela `--simulate` (`-s`).

### Gérer vos packages
Vous pouvez obtenir la liste des packages installés avec `minpkg ls` ou `minpkg ll`.

Si vous voulez vérifier si vous avez installé un certain package, cherchez-le avec `minpkg find PACKAGE`.

Pour afficher la liste des versions installées d'un package, utilisez `minpkg versions PACKAGE`.

Vous pouvez aussi afficher quelques informations sur un package installé avec `minpkg infos PACKAGE`.

Vous pouvez ajouter une description à un package avec `minpkg describe PACKAGE`.

Si un package fonctionne mal, vous pouvez essayer de le réparer avec `minpkg repair PACKAGE`. Cela recrée les symlinks entre le package installé dans la base de données de minpkg (typiquement `/usr/pkgs`) et votre système lui-même (`/`). Cela peut par exemple être utile pour changer de version parmi celles installées d'un package ou si vous avez altéré manuellement les fichiers du package après son installation.

### Supprimer un package
Supprimer un package est aussi simple qu'entrer `minpkg remove PACKAGE` (ou `minpkg - PACKAGE`). Si plusieurs versions sont installées, le programme vous demandera laquelle supprimer.

Une fois l'action confirmée, cette procédure est irréversible!

### Mettre à jour et gérer son kernel
minpkg vient avec krnlupd, un outil de gestion et de mise à jour du kernel. Cet outil est encore plus minimal que minpkg, puisqu'il assume que vous avez déjà configuré, compilé et installé un kernel manuellement et que vous en avez conservé les sources. krnlupd est utile pour apporter des modifications à ce kernel déjà présent en faisant appel à `make menuconfig`. Il permet d'automatiser la suite après la configuration.

Tout comme minpkg (depuis la version 1.6.4), krnlupd doit être configuré lors de sa première utilisation. Ceci se fait automatiquement.

Vous pouvez aussi appeler krnlupd via minpkg avec la commande `minpkg kernel` et  `minpkg kernel-infos`. Toutes les fonctionnalités des krnlupd y sont présentes.

## En apprendre plus
Pour en apprendre plus sur le fonctionnement de minpkg, lancez-le avec l'option `--comprendre`.

L'option `--help` (`-h` ou `-?`) offre aussi la liste des commandes et options acceptées par le programme, ce qui constitue un bon point de départ pour savoir comment utiliser ce programme.
