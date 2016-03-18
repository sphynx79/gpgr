
# Gpgr: Criptare e descriptare dati con gpg in Ruby
&nbsp;

[TOC]

&nbsp;

### Introduzione
Applicazione scritta in ruby per crittografia di dati attraverso **gnupg**.
&nbsp;

### Descrizione
Ho creato questa applicazione perchè aveva la necessità di criptare file importanti senza lasciare tracce nella macchina in cui viene eseguita, per un ottimo livello di crittografia mi sono affidato a [Gnupg](https://www.gnupg.org/), per quantyo riguarda l'eliminazione dei file in modo permanente mi appoggio all'utility  [Eraser](http://eraser.heidi.ie/).
Per i passaggi intermedi utilizzo l'utility [7-zip](www.7-zip.org/).
&nbsp;


### Utilizzo
L'ulizzo è molto semplice l'applicativo funziona da linea di comando, per l'help:
```
ruby gpg.rb -h

Usage: gpgr2.exe -e -p file -m mode
Options
    -d, --decrypt                    Start in decrypt mode
    -e, --encrypt                    Start in encrypt mode
    -p, --path PATH                  Path della directory o del file da utilizzare
    -m, --method METHOD              Algoritmo usato da eraser per eliminare i file
    -h, --help                       Display this screen
```
Di defaul per l'elimanzione dei file viene usato il metodo Gutmann(35 pass), è possibile selezionare tra i metodi disponibili (Gutmann|DoD|DoD_E|First_Last2k|Schneier|Random|Library) quello desiderato passandolo come argomento al parametr \--method.
Per maggiori informazioni sui metodi disponibili vedere la documentazione di Eraser.

##### Criptare
```
ruby gpg.rb -e -p "YOUR_PATH_DATA"
```
E' possibile specificare il metodo di eliminazione:
```
ruby gpg.rb -e -m Schneier -p "YOUR_PATH_DATA"
```

##### Decriptare
```
ruby gpg.rb -d -p "YOUR_CRIPT_FILE"
```
E' possibile specificare il metodo di eliminazione:
```
ruby gpg.rb -d -m Schneier -p "YOUR_CRIPT_FILE"
```
&nbsp;


### Dimostrazione
<iframe width="560" height="315" src="http://www.youtube.com/embed/QH2-TGUlwu4" frameborder="0"></iframe>

