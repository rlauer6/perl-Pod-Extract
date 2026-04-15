#-*- mode: makefile; -*-

PERL_MODULES_IN = $(PERL_MODULES:.pm=.pm.in)
BIN_FILES_IN = $(BIN_FILES:=.in)

RECOMMENDED_ARTIFACTS = \
     README.md \
     Makefile \
     version.mk \
     release-notes.mk \
     $(PERL_MODULES_IN) \
     $(BIN_FILES_IN) \
     $(TESTS) \
     ChangeLog \
     buildspec.yml \
     VERSION \
     requires \
     test-requires \
     .gitignore

.PHONY: git
git: ## initializes a git repository and commits the recommended artifacts
	git init -b main
	git add $(RECOMMENDED_ARTIFACTS)
	git commit -m 'BigBang'

