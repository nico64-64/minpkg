# MINPKG

***a MINimal PacKaGe manager***<br>
Un package manager minimal.

## Description
minpkg n'est pas un package manager comme les autres. En fait, on pourrait même argumenter que ce n'en est pas vraiment un. Ce n'est à la base qu'un script bash servant de wrapper autour des différents systèmes de construction des packages.

Les principales différences avec un package manager normal sont que:
- minpkg est utilise le code source des packages (et non leurs binaires précompilés)
- minpkg fonctionne en local seulement (vous devez télécharger vous-même les sources des packages que vous voulez installer)
- minpkg offre plus de contrôle (vous devez par contre savoir comment construire vos packages)
- minpkg est facile à comprendre de A à Z
- minpkg permet de conserver plusieurs copies (versions) d'un même package

Les principales différences par rapport à la compilation manuelle sont que:
- l'installation se fait en une seule commande (au lieu des 3 traditionnelles)
- il est très facile de savoir quels fichiers ont été installés par quel package
- il est très facile de savoir quels packages ont été installés, et comment, quand, par qui, etc.

En date de la version 1.5.9, minpkg supporte les systèmes suivants:
- Décompression: tar, zip
- Configuration: autoconf (`./configure`), cmake, meson, perl
- Construction: make, ninja, pip3
- Test: make, ninja
- Installation: make, ninja, pip3

(*) Les packages installés avec pip3 ne sont pas gérés par minpkg.

## Installation

### Installation standard:
Lancez l'installation de minpkg en exécutant simplement le script fourni:
```bash
chmod +x install.sh
./install.sh
```
Si vous ne recevez aucune erreur, vous pouvez ensuite supprimer les fichiers téléchargés. En cas d'erreur, essayez de faire une installation personnalisée.

**Note:** Un `Attention!`(jaune) n'est pas une `Erreur!`(rouge)! Vous pouvez ignorer les premiers sans problème.

### Installation personnalisée:
Lancez le script d'installation avec la commande `./install.sh --help` pour obtenir la liste des options acceptées.<br>
Les options les plus utiles et/ou difficiles à comprendre sont expliquées ici:

`--default-prefix=...`: minpkg utilise l'option `--prefix=...` lors de la configuration des packages. Par défaut, ce préfixe est /usr, mais vous pouvez le changer ici (par exemple en spécifiant `--prefix=/usr/local` si vous ne voulez pas mélanger les packages installés par minpkg avec ceux installés par votre package manager système).

`--pkgs-path=...`: Cette option permet de changer l'endroit où sont réellement installés les packages.<br>
Il n'y a pas vraiment de raison de changer la valeur par défaut (/usr/pkgs).

`--without-installing`: Cette option au nom assez paradoxal n'est utile que sur un système à plusieurs usagers. Sur un tel système, le script install.sh devrait être exécuté avec cette option par tous les autres usagers après l'installation de minpkg. Ce n'est pas nécessaire si ces usagers n'utilisent pas minpkg.

`--without-root-cache`: Vous pouvez utiliser cette option si vous ne voulez pas créer de dossiers/fichiers dans le répertoire /root. Si vous le faites, vous ne pourrez pas utiliser minpkg en tant que root. Vous pouvez toujours changer d'idée plus tard et créer ces dossiers manuellement ou en réexécutant ce script.

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
Par défaut, minpkg créera aussi un nouveau dossier nommé "build" à l'intérieur des sources du package. Le package sera construit depuis ce dossier. Plusieurs packages recommandent de les construire ainsi, mais cela peut poser problème avec d'autres. Vous pouvez donc désactiver cette fonctionnalité avec `--no-build-dir` (`-n`).

Par défaut, minpkg tente aussi d'enlever les symboles de débogage, mais cela ne fonctionne pas toujours. Si vous recevez une erreur de type "no target for 'install-strip'", installez le package avec `--no-strip`.

Il peut parfois être utile de décompresser soi-même le package puis de lui appliquer des modifications (comme une patch) avant de l'installer avec minpkg. Dans ce cas, si le package utilise autoconf pour se configurer, il est fort probable que la construction avec minpkg échoue avec une erreur de type "aclocal not found". Cela est causé par le fait que minpkg copie d'abord les sources avant de les utiliser. Cela réinitialise les timestamps des fichiers, et autoconf juge donc qu'il doit regénérer ses fichiers, et cela nécessite une certaine version d'autoconf qui n'est pas celle que vous avez installée. Par contre, ces fichiers n'ont souvent pas réellement besoin d'être regénérés. minpkg fournit donc une option (`--fix-aclocal`) qui ajuste les timestamps des fichiers nécessaires pour contenter autoconf.

Vous pouvez aussi construire vos packages sans les installer pour d'abord vérifier si minpkg est bien capable de les construire. Utilisez pour cela `--simulate` (`-s`).

### Gérer vos packages
Vous pouvez obtenir la liste des packages installés avec `minpkg list`, `minpkg ls` ou `minpkg ll`.

Pour afficher la liste des versions installées d'un package, utilisez `minpkg versions PACKAGE`.

Vous pouvez aussi afficher quelques informations sur un package installé avec `minpkg infos PACKAGE`.

Vous pouvez ajouter une description à un package avec `minpkg describe PACKAGE`.

Si un package fonctionne mal, vous pouvez essayer de le réparer avec `minpkg repair PACKAGE`. Cela recrée les symlinks entre le package installé dans la base de données de minpkg (typiquement `/usr/pkgs`) et votre système lui-même (`/`). Cela peut par exemple être utile pour changer de version parmi celles installées d'un package ou si vous avez altéré manuellement les fichiers du package après son installation.

### Supprimer un package
Supprimer un package est aussi simple qu'entrer `minpkg remove PACKAGE` (ou `minpkg - PACKAGE`). Si plusieurs versions sont installées, le programme vous demandera laquelle supprimer.

Une fois l'action confirmée, cette procédure est irréversible!

## En apprendre plus
Pour en apprendre plus sur le fonctionnement de minpkg, lancez-le avec l'option `--comprendre`.

L'option `--help` (`-h` ou `-?`) offre aussi la liste des commandes et options acceptées par le programme, ce qui constitue un bon point de départ pour savoir comment utiliser ce programme.
