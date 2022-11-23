DIST=Pod-Extract.tar.gz

all: $(DIST)

DIST_FILES = \
    README.md \
    lib/Pod/Extract.pm \
    bin/podextract.pl

POD = \
    lib/Pod/Extract.pod

$(POD): lib/Pod/Extract.pm
	perldoc -u -T $< > $@

README.md: $(POD)
	pod2markdown $< > $@

$(DIST): $(DIST_FILES)
	cp bin/podextract.pl bin/podextract; \
	make-cpan-dist -v \
	  -a "Rob Lauer <rclauer@gmail.com>" \
	  -d 'extract from pod from scripts or modules' \
	  -l lib \
	  -r scandeps-static.pl \
	  -m Pod::Extract \
	  -e bin
	ln -s $$(ls -rt *.tar.gz | tail -1) $@

clean:
	rm -f *.tar.gz
	rm -f bin/podextract
	rm -f requires provides
