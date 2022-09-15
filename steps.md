# Lancer une application dans k8s

Alors pour déployer dans kubernetes sans rien d'autre pas de (`helm create {monAppli}`, `fluxcd`) etc... Je ferais : 
1 - Construire une image docker 
2 - Créer un déployment avec son service ainsi que son ingress
3 - L'exposer par le billet d'un service
4 - Créer un ingress pour qu'il soit atteint depuis l'exterieur par DNS

(Je te joins les fichiers dans le dépot)

Pour générer les manifests pour ne plus avoir à le faire dans le future, j'utiliserai les commandes suivantes : 

**Le namespace**

Je commence par construire le namespace car les autres ressources étant namespaced, je risque d'avoir un souci si le namespace n'existe pas encore à la création des autres ressources API

`kubectl create ns python-application --dry-run=client -o yaml > ns.yml`

Après, l'autre à peu d'importance à mon sens car le service ira matcher le label du déploiment qu'il arrive avant ou après

**Le déploiment**

`kubectl create deployment simple-app-py --image=challenge:latest --namespace=python-application --dry-run=client -o yaml > mydeployment.yml`

**Le service clusterIP**

`kubectl expose deployment simple-app-py --namespace=python-application --port=5000 --target-port=5000 --dry-run=client -o yaml`

**L'ingress**

`kubectl create ingress simple-app-py --namespace=python-application --rule="foo-py.com/=simple-app-py=:5000,tls=foo-py-cert" --dry-run=client -o yaml > ingress-py.yml`


l'idée c'est de pas faire de fautes dans la rédaction des fichiers yaml (problème d'indentation et syntaxe). Pour le service on peut aussi le créer de toute pièce mais je trouve ça pratique d'utiliser `expose` car ça m'évite de me tromper dans les label et selector et avoir un souci de match (ça nécessite d'instancier temporairement le deploiment quand même car je peux pas exposer un deploiment qui n'existe pas mais par la suite, je n'aurai plus besoin de faire ça)

tout ces fichiers étant dans un même dossier je ferai ensuite un :

`for i in ns.yml svc.yml ingress-py.yml mydeployment.yml; do kubectl apply -f $i; done`

Je commence par lancer le namespace dans un premier temps, après la suite peu importe.yml
Voilà comment je ferai si je n'avais qu'un k8s vanilla ! 

Autrement j'utiliserai une chart qui ressemble à ça (voir: chart-app-simple-py)

Concernant un process de CI/CI j'utiliserai gitlab CI/CD. Via gitlab, je procéde à la création d'image Docker (j'aime bien utiliser kaniko qui permet de faire du docker in docker) 

1 - Une fois l'image docker construit, je stock celle-ci dans un registry

2 - Pour la partie CD, soit j'utilise fluxcd afin de le laisser procéder à la reconciliation entre git et k8s. Sinon sans ça. Je pense que j'opterai pour prendre un master du cluster k8s en tant que runner gitlab et y installer les chart helm (un git pull du projet suivi d'un `helm install` de ma chart avec le fichier de value adéquat)
Bonne journée à toi ! 

# Description d'un pipeline CI/CD
