# Makefile ispell-gaeilge
# INSTALLATION=gaeilgemor
# INSTALLATION=gaeilgelit
INSTALLATION=gaeilge
ISPELLDIR=/usr/lib/ispell
ISPELLBIN=/usr/bin
INSTALL=/usr/bin/install
SHELL=/bin/sh
MAKE=/usr/bin/make
PERSONAL=aitiuil daoine eachtar gall giorr gno logainm miotas.txt romhanach stair.txt

#   Shouldn't have to change anything below here
RELEASE=4.3
RAWWORDS= gaeilge.raw
LITWORDS= gaeilge.lit
ALTWORDS= gaeilge.mor
AFFIXFILE= gaeilge.aff
ALTAFFIXFILE=gaeilgemor.aff
INSTALL_DATA=$(INSTALL) -m 444

SORT=/usr/bin/sort -u

hashtable: $(INSTALLATION).hash

all: gaeilge.hash gaeilgelit.hash gaeilgemor.hash

gaeilge.hash: $(RAWWORDS) $(AFFIXFILE) $(PERSONAL)
	$(SORT) $(RAWWORDS) $(PERSONAL) | LC_ALL=C grep -v "[^'a-zA-Z����������/-]" > gaeilge.focail
	$(ISPELLBIN)/buildhash gaeilge.focail $(AFFIXFILE) gaeilge.hash
#	rm -f gaeilge.focail

gaeilgelit.hash: $(RAWWORDS) $(LITWORDS) gaeilgelit.aff $(PERSONAL)
	$(SORT) $(RAWWORDS) $(LITWORDS) $(PERSONAL) | LC_ALL=C grep -v "[^'a-zA-Z����������/-]" > gaeilge.focail
	$(ISPELLBIN)/buildhash gaeilge.focail gaeilgelit.aff gaeilgelit.hash
	rm -f gaeilge.focail

gaeilgemor.hash: $(RAWWORDS) $(LITWORDS) $(ALTWORDS) $(ALTAFFIXFILE) $(PERSONAL)
	$(SORT) $(RAWWORDS) $(LITWORDS) $(ALTWORDS) $(PERSONAL) | LC_ALL=C grep -v "[^'a-zA-Z����������/-]" > gaeilge.focail
	$(ISPELLBIN)/buildhash gaeilge.focail $(ALTAFFIXFILE) gaeilgemor.hash
	rm -f gaeilge.focail

$(ALTAFFIXFILE): $(AFFIXFILE) gaeilgemor.diff
	patch -o gaeilgemor.aff gaeilge.aff < gaeilgemor.diff

personal: biobla $(PERSONAL)
	LC_ALL=ga_IE sort -u $(PERSONAL) > ./personal
	rm -f $(HOME)/.ispell_$(INSTALLATION)
	LC_ALL=ga_IE sort -u biobla > $(HOME)/.ispell_$(INSTALLATION)

gaeilgelit.aff: $(AFFIXFILE)
	cp $(AFFIXFILE) gaeilgelit.aff

install: $(INSTALLATION).hash $(INSTALLATION).aff
	$(INSTALL_DATA) $(INSTALLATION).hash $(ISPELLDIR)
	$(INSTALL_DATA) $(INSTALLATION).aff $(ISPELLDIR)

installall: gaeilge.hash gaeilgelit.hash gaeilgemor.hash gaeilgelit.aff
	$(INSTALL_DATA) gaeilge.hash $(ISPELLDIR)
	$(INSTALL_DATA) $(AFFIXFILE) $(ISPELLDIR)
	$(INSTALL_DATA) gaeilgelit.hash $(ISPELLDIR)
	$(INSTALL_DATA) gaeilgelit.aff $(ISPELLDIR)
	$(INSTALL_DATA) gaeilgemor.hash $(ISPELLDIR)
	$(INSTALL_DATA) $(ALTAFFIXFILE) $(ISPELLDIR)

clean:
	rm -f *.cnt *.stat *.bak *.tar *.tar.gz *.full gaeilge sounds.txt ga.cwl repl aspellrev.txt IG2.* EN.temp IG.missp IG.temp IG.temp2 personal accents.txt

distclean:
	$(MAKE) clean
	rm -f *.hash aspell.txt aspelllit.txt aspellalt.txt ga_IE.dic gaeilgelit.aff $(ALTAFFIXFILE) ga_IE.aff gaelu giorr

#############################################################################
### Remainder is for development only
#############################################################################

APPNAME=ispell-gaeilge-$(RELEASE)
MYAPPNAME=hunspell-gaeilge-$(RELEASE)
TARFILE=$(APPNAME).tar
MYTARFILE=$(MYAPPNAME).tar
CODEDIR=$(HOME)/clar/denartha
GIN=$(CODEDIR)/Gin
ASPELL=/usr/bin/aspell
MYSPELL=/usr/local/bin/hunspell

gaeilgehyph.hash: gaeilge.hyp gaeilgehyph.aff
	$(ISPELLBIN)/buildhash gaeilge.hyp gaeilgehyph.aff gaeilgehyph.hash


gaeilgemor.diff:
	(diff -c $(AFFIXFILE) $(ALTAFFIXFILE) > gaeilgemor.diff; echo)

# like "maintainer" clean -- distclean PLUS kill files that are makeable
# from backend database
veryclean:
	$(MAKE) distclean
	rm -f athfhocail gaeilge.raw gaeilge.lit gaeilge.mor miotas.txt stair.txt romhanach README_ga_IE.txt ChangeLog

# flip BH for historical compat, clean CVS
fromdb : FORCE
	$(GIN) 7
	sed -i 's/\/BH/\/HB/' gaeilge.raw gaeilge.lit gaeilge.mor
	$(MAKE) sort
	$(MAKE) all

# must keep sort this way so "join" works in gramadoir-ga makefile...
athfromdb : FORCE
	$(GIN) 10
	LC_ALL=C sort -u athfhocail fgbalts.txt myalts.txt | LC_ALL=C sort -k1,1 > tempfile
	mv -f tempfile athfhocail

# GNU sort ignores "/" so words don't come out in correct alphabetical
# order, which is desirable for readability and clean CVS logs
GOODSORT=bash ./isort

sort: FORCE
	$(GOODSORT) $(RAWWORDS) > tempfile
	mv tempfile $(RAWWORDS)
	$(GOODSORT) $(LITWORDS) > tempfile
	mv tempfile $(LITWORDS)
	$(GOODSORT) $(ALTWORDS) > tempfile
	mv tempfile $(ALTWORDS)

giorr : giorr.in
	cat giorr.in | LC_ALL=C sed 's/ .*//' | LC_ALL=ga_IE sort -f > $@

# giorr done above
sortpersonal: FORCE
	LC_ALL=C sort -f aitiuil > tempfile
	mv tempfile aitiuil
	LC_ALL=C sort -f daoine > tempfile
	mv tempfile daoine
	LC_ALL=C sort -f eachtar > tempfile
	mv tempfile eachtar
	LC_ALL=C sort -f gall > tempfile
	mv tempfile gall
	LC_ALL=C sort -f gno > tempfile
	mv tempfile gno
	LC_ALL=C sort -f logainm > tempfile
	mv tempfile logainm
	LC_ALL=C sort -f miotas > tempfile
	mv tempfile miotas
	LC_ALL=C sort -f stair > tempfile
	mv tempfile stair
	LC_ALL=C sort -f gaelu.in > tempfile
	mv tempfile gaelu.in
	LC_ALL=C sort -f earraidi > tempfile
	mv tempfile earraidi
	LC_ALL=C sort -f uimhreacha > tempfile
	mv tempfile uimhreacha
	LC_ALL=C sort -f myalts.txt > tempfile
	mv tempfile myalts.txt

stair.txt : stair
	LC_ALL=ga_IE sed 's/^[^:]*://' stair | LC_ALL=ga_IE sort -u > $@

miotas.txt : miotas
	LC_ALL=ga_IE sed 's/^[^:]*://' miotas | LC_ALL=ga_IE sort -u > $@

romhanach : roman.pl
	perl roman.pl > $@

accents.txt : aspell.txt
	cat aspell.txt | iconv -f iso-8859-1 -t utf8 > aspell8.txt
	comh.pl -a aspell8.txt | sed 's/: / /' > accents-a.txt
	counts.pl /usr/local/share/crubadan/ga/FREQ.aimsigh accents-a.txt | perl -p -e '/([^ ]+) ([0-9]+) ([^ ]+) ([0-9]+)$$/; if ($$2 == 0) {$$ans='INF';} else {$$ans=$$4/$$2;} s/^/$$ans /;' | sort -k1,1 -n -r -k5,5 -n -r > $@
	rm -f aspell8.txt accents-a.txt

# compare eilefromdb target in gramadoir-ga Makefile
validalts.txt : aspell.txt athfhocail
	LC_ALL=C sed 's/ .*//' athfhocail | keepif ./aspell.txt latin-1 | LC_ALL=C sort -u | LC_ALL=C join athfhocail - | LC_ALL=C sort -k1,1 | egrep '^' | iconv -f iso-8859-1 -t utf-8 > ./tempvalid.txt
	counts.pl /usr/local/share/crubadan/ga/FREQ.aimsigh tempvalid.txt | sort -k4,4 -r -n > $@
	rm -f tempvalid.txt

checkearr: aspelllit.txt
	$(MAKE) gaelu
	LC_ALL=C sort -u aspelllit.txt $(PERSONAL) > a.tmp
	LC_ALL=C sed 's/^[^ ]* //' earraidi | tr " " "\n" | keepif -n ./a.tmp latin-1 | LC_ALL=ga_IE sort -u
	LC_ALL=C sed 's/^[^ ]* //' athfhocail | tr " " "\n" | keepif -n ./a.tmp latin-1 | LC_ALL=ga_IE sort -u
	LC_ALL=C sed 's/^[^ ]* //' gaelu | LC_ALL=C grep -v "[^'a-zA-Z����������-]" | keepif -n ./a.tmp latin-1 | LC_ALL=ga_IE sort -u
	rm -f a.tmp

gaelu: gaelu.in
	LC_ALL=ga_IE bash buildgael > gaelu

count: aspell.txt
	cat aspell.txt | wc -l

litcount: aspelllit.txt
	cat aspelllit.txt | wc -l

altcount: aspellalt.txt
	cat aspellalt.txt | wc -l

allcounts: FORCE 
	@$(MAKE) aspell.txt aspelllit.txt aspellalt.txt
	@$(GIN) 9
	@echo 'Leagan caighde�nach:'
	@egrep "]:.." igtemp | wc -l
	@echo 'ceannfhocal agus'
	@$(MAKE) count
	@echo 'focal infhillte'
	@echo 'Leagan litearta:'
	@$(MAKE) litcount
	@echo 'focal infhillte'
	@echo 'Leagan can�nach:'
	@$(MAKE) altcount
	@echo 'focal infhillte'
	@rm -f igtemp

full: gaeilge.hash
	cat $(RAWWORDS) | $(ISPELLBIN)/ispell -d./gaeilge -e3 > gaeilge.full

litfull: gaeilgelit.hash
	cat $(RAWWORDS) $(LITWORDS) | $(ISPELLBIN)/ispell -d./gaeilgelit -e3 > gaeilgelit.full

altfull: gaeilgemor.hash
	cat $(RAWWORDS) $(LITWORDS) $(ALTWORDS) | $(ISPELLBIN)/ispell -d./gaeilgemor -e3 > gaeilgemor.full

aspell.txt: gaeilge.hash
	cat $(RAWWORDS) | $(ISPELLBIN)/ispell -d./gaeilge -e3 | tr " " "\n" | egrep -v '\/' | LC_ALL=ga_IE sort -u > aspell.txt

aspelllit.txt: gaeilgelit.hash
	cat $(RAWWORDS) $(LITWORDS) | $(ISPELLBIN)/ispell -d./gaeilgelit -e3 | tr " " "\n" | egrep -v '\/' | LC_ALL=ga_IE sort -u > aspelllit.txt

aspellalt.txt: gaeilgemor.hash
	cat $(RAWWORDS) $(LITWORDS) $(ALTWORDS) | $(ISPELLBIN)/ispell -d./gaeilgemor -e3 | tr " " "\n" | egrep -v '\/' | LC_ALL=ga_IE sort -u > aspellalt.txt

# these aspell function are unimplemented according to K.A. 7/2/03
apersonal: $(PERSONAL) giorr
	(echo "personal_repl-1.1 ga 0"; LC_ALL=ga_IE sort -u athfhocail earraidi gaelu) > repl
	cp -f repl $(HOME)/.aspell.ga.prepl
#	(echo "personal_ws-1.1 ga 0"; sort -u $(PERSONAL)) > pearsanta
#	cp -f pearsanta $(HOME)/.aspell.ga.pws
#	rm -f $(HOME)/.aspell.ga.rpl
#	cat athfhocail | $(ASPELL) --lang=ga create repl $(HOME)/.aspell.ga.rpl
#	rm -f $(HOME)/.aspell.ga.per
#	sort -u $(PERSONAL) | $(ASPELL) --lang=ga create personal $(HOME)/.aspell.ga.per < tempwords 

installweb: FORCE
	$(INSTALL_DATA) index.html $(HOME)/public_html/ispell
	$(INSTALL_DATA) index-en.html $(HOME)/public_html/ispell
	$(INSTALL_DATA) sonrai.html $(HOME)/public_html/ispell
	$(INSTALL_DATA) sios.html $(HOME)/public_html/ispell

dist: FORCE
	$(MAKE) ChangeLog stair.txt miotas.txt romhanach giorr
	sed '/development only/,$$d' ./Makefile > makefile
	chmod 644 $(AFFIXFILE) gaeilgemor.diff $(RAWWORDS) $(LITWORDS) $(ALTWORDS) COPYING README ChangeLog makefile aitiuil biobla daoine eachtar gall giorr gno logainm miotas.txt romhanach stair.txt makefile
	chmod 755 igcheck
	ln -s ispell-gaeilge ../$(APPNAME)
	tar cvhf $(TARFILE) -C .. $(APPNAME)/$(AFFIXFILE) 
	tar rvhf $(TARFILE) -C .. $(APPNAME)/gaeilgemor.diff
	tar rvhf $(TARFILE) -C .. $(APPNAME)/$(RAWWORDS) 
	tar rvhf $(TARFILE) -C .. $(APPNAME)/$(LITWORDS) 
	tar rvhf $(TARFILE) -C .. $(APPNAME)/$(ALTWORDS) 
	tar rvhf $(TARFILE) -C .. $(APPNAME)/COPYING
	tar rvhf $(TARFILE) -C .. $(APPNAME)/ChangeLog
	tar rvhf $(TARFILE) -C .. $(APPNAME)/README
	tar rvhf $(TARFILE) -C .. $(APPNAME)/makefile
	tar rvhf $(TARFILE) -C .. $(APPNAME)/aitiuil
	tar rvhf $(TARFILE) -C .. $(APPNAME)/biobla
	tar rvhf $(TARFILE) -C .. $(APPNAME)/daoine
	tar rvhf $(TARFILE) -C .. $(APPNAME)/eachtar
	tar rvhf $(TARFILE) -C .. $(APPNAME)/gall
	tar rvhf $(TARFILE) -C .. $(APPNAME)/giorr
	tar rvhf $(TARFILE) -C .. $(APPNAME)/gno
	tar rvhf $(TARFILE) -C .. $(APPNAME)/igcheck
	tar rvhf $(TARFILE) -C .. $(APPNAME)/logainm
	tar rvhf $(TARFILE) -C .. $(APPNAME)/miotas.txt
	tar rvhf $(TARFILE) -C .. $(APPNAME)/romhanach
	tar rvhf $(TARFILE) -C .. $(APPNAME)/stair.txt
	gzip $(TARFILE)
	rm -f ../$(APPNAME)
	rm -f makefile

ga_IE.dic: $(RAWWORDS)
	rm -f ga_IE.dic
	$(GOODSORT) $(RAWWORDS) $(PERSONAL) > tempfile
	cat tempfile | wc -l | tr -d " " > tempcount
	cat tempcount tempfile > ga_IE.dic
	rm -f tempfile tempcount

ga_IE.aff: $(AFFIXFILE) myspell-header hunspell-header
	cat myspell-header hunspell-header > myspelltemp.txt
	${HOME}/clar/libexec/ispellaff2myspell --charset=latin1 gaeilge.aff --myheader myspelltemp.txt | sed 's/""/0/' | sed '40,$$s/"//g' | perl -p -e 's/^PFX S( +)([a-z])( +)[a-z]h( +)[a-z](.*)/print "PFX S$$1$$2$$3$$2h$$4$$2$$5\nPFX S$$1\u$$2$$3\u$$2h$$4\u$$2$$5";/e' | sed 's/S Y 9$$/S Y 18/' | sed 's/\([]A-Z]\)1$$/\1/' > ga_IE.aff
	rm -f myspelltemp.txt

mycheck: ga_IE.dic aspell.txt ga_IE.aff
	cat aspell.txt | $(MYSPELL) -l -d ./ga_IE

README_ga_IE.txt: README COPYING
	(echo; echo "1. Version"; echo; echo "This is version $(RELEASE) of hunspell-gaeilge."; echo; echo "2. Copyright"; echo; cat README; echo; echo "3. Copying"; echo; cat COPYING) > README_ga_IE.txt

mydist: ga_IE.dic README_ga_IE.txt ga_IE.aff install.rdf install.js
	rm -f thes.txt hyph_ga_IE.zip ga_IE.zip
	rm -Rf dictionaries
	chmod 644 ga_IE.dic ga_IE.aff README_ga_IE.txt
	zip ga_IE ga_IE.dic ga_IE.aff README_ga_IE.txt
	chmod 644 ga_IE.zip
	echo 'ga,IE,hyph_ga_IE,Irish (Ireland),hyph_ga_IE.zip' > hyph.txt
	echo 'ga,IE,ga_IE,Irish (Ireland),ga_IE.zip' > spell.txt
	echo 'ga,IE,thes_ga_IE_v2,Irish (Ireland),thes_ga_IE_v2.zip' > thes.txt
	wget http://ftp.services.openoffice.org/pub/OpenOffice.org/contrib/dictionaries/hyph_ga_IE.zip
	wget http://ftp.services.openoffice.org/pub/OpenOffice.org/contrib/dictionaries/thes_ga_IE_v2.zip
	zip ga_IE-pack ga_IE.zip hyph.txt hyph_ga_IE.zip spell.txt thes.txt thes_ga_IE_v2.zip
	mkdir dictionaries
	cp ga_IE.dic dictionaries
	cp ga_IE.aff dictionaries
	cp README_ga_IE.txt dictionaries
	zip -r ga-IE-dictionary.xpi dictionaries install.rdf install.js
	rm -Rf dictionaries hyph.txt spell.txt thes.txt

mytardist: ga_IE.dic ChangeLog
	cp README README.txt
	chmod 644 ga_IE.dic ga_IE.aff COPYING README.txt
	ln -s ispell-gaeilge ../$(MYAPPNAME)
	tar cvhf $(MYTARFILE) -C .. $(MYAPPNAME)/ga_IE.dic
	tar rvhf $(MYTARFILE) -C .. $(MYAPPNAME)/ga_IE.aff
	tar rvhf $(MYTARFILE) -C .. $(MYAPPNAME)/COPYING
	tar rvhf $(MYTARFILE) -C .. $(MYAPPNAME)/ChangeLog
	tar rvhf $(MYTARFILE) -C .. $(MYAPPNAME)/README.txt
	gzip $(MYTARFILE)
	rm -f ../$(MYAPPNAME) README.txt

ga.cwl: aspell.txt
	LANG=C; export LANG; cat aspell.txt | sort -u | word-list-compress c > ga.cwl

ASPELLDEV = ${HOME}/gaeilge/gramadoir/ga/aspell

adist: aspell.txt apersonal ChangeLog
	LC_ALL=C sort -u aspell.txt $(PERSONAL) > a.tmp
	chmod 644 a.tmp README README.aspell gaeilge_phonet.dat info repl gaeilge.dat
	cp -f README $(ASPELLDEV)/Copyright
	cp -f README.aspell $(ASPELLDEV)/doc/README
	cp -f gaeilge_phonet.dat $(ASPELLDEV)/ga_phonet.dat
	cp -f a.tmp $(ASPELLDEV)/aspell.txt
	cp -f info $(ASPELLDEV)
	cp -f repl $(ASPELLDEV)/doc
	cp -f ChangeLog $(ASPELLDEV)/doc
	cp -f gaeilge.dat $(ASPELLDEV)/ga.dat
	aspellproc ga
	mv ${ASPELLDEV}/*.bz2 .
	sed -i '/^mode aspell5/d' $(ASPELLDEV)/info
	aspellproc ga
	mv ${ASPELLDEV}/*.bz2 .
	rm -f a.tmp

ChangeLog : FORCE
	cvs2cl --FSF

sounds.txt: FORCE
	$(ASPELL) --lang=ga soundslike < aspell.txt > sounds.txt

aspellrev.txt: aspell.txt
	cat aspell.txt | perl -p -e 's/(.*)/reverse $$1/e;' | sort | perl -p -e 's/(.*)/reverse $$1/e;' > aspellrev.txt 

seiceail: FORCE
	@$(MAKE) fromdb
	@$(MAKE) aspelllit.txt
#	@$(GIN) 2   # rebuilds Eng-Ir dict.
	@$(GIN) 8   # creates local EN.temp, IG.temp
#	@cat EN.temp | $(ISPELLBIN)/ispell -l | sort -u | egrep -v \' > EN.temp2
#	@diff -w EN.temp2 ../bearla/Missp | egrep "<" > EN.missp
	@cat IG.temp | tr " " "\n" | LC_ALL=ga_IE sort -u > IG.temp2
	@diff -w aspelllit.txt IG.temp2 | egrep '^[<>]' | egrep -v '^> [A-Z�����]' > IG.missp
	@egrep '^>' IG.missp | sed 's/^> //' > IG2.txt
	@cat IG2.txt | gram-ga.pl --aschod=iso-8859-1 --litriu > IG2.mis
	@diff -u IG2.txt IG2.mis
	@rm -f EN.temp EN.temp2 IG.temp2 IG2.txt IG2.mis
#	@$(MAKE) distclean
# the stuff in IG.missp should be mostly be labelled ">", meaning they are 
# words generated by "all_inflections", but hopefully just from compound
# words like "d�an a bheag de" where the inflection code isn't done
# and you get "dh�anadar" vs. "rinneadar", etc.   This can be checked
# by simply running these ">" words thru "gr --litriu", all should show
# up as misspelled.
#   Anything with a "<" is more worrisome; these are either 
#   things incorrectly absent from all_inflections (hence Gramadoir)
#   or else unwanted things in ispell generation code (fhuarthas was 
#   discovered this way)

FORCE:
