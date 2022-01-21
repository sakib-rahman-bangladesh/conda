SHELL := /bin/bash -o pipefail -o errexit

clean:
	find . -name \*.py[cod] -delete
	find . -name __pycache__ -delete
	rm -rf .cache build
	rm -f .coverage .coverage.* junit.xml tmpfile.rc conda/.version tempfile.rc coverage.xml
	rm -rf auxlib bin conda/progressbar
	rm -rf conda-build conda_build_test_recipe record.txt
	rm -rf .pytest_cache


clean-all:
	@echo Deleting everything not belonging to the git repo:
	git clean -fdx


anaconda-submit-test: clean-all
	anaconda build submit . --queue conda-team/build_recipes --test-only


anaconda-submit-upload: clean-all
	anaconda build submit . --queue conda-team/build_recipes --label stage


# VERSION=0.0.41 make auxlib
auxlib:
	git clone https://github.com/kalefranz/auxlib.git --single-branch --branch $(VERSION) \
	    && rm -rf conda/_vendor/auxlib \
	    && mv auxlib/auxlib conda/_vendor/ \
	    && rm -rf auxlib


# VERSION=16.4.1 make boltons
boltons:
	git clone https://github.com/mahmoud/boltons.git --single-branch --branch $(VERSION) \
	    && rm -rf conda/_vendor/boltons \
	    && mv boltons/boltons conda/_vendor/ \
	    && rm -rf boltons


# VERSION=0.8.0 make toolz
toolz:
	git clone https://github.com/pytoolz/toolz.git --single-branch --branch $(VERSION) \
	    && rm -rf conda/_vendor/toolz \
	    && mv toolz/toolz conda/_vendor/ \
	    && rm -rf toolz
	rm -rf conda/_vendor/toolz/curried conda/_vendor/toolz/sandbox conda/_vendor/toolz/tests


pytest-version:
	pytest --version


smoketest:
	pytest tests/test_create.py -k test_create_install_update_remove


unit:
	pytest -m "not integration and not installed"


integration: clean pytest-version
	pytest -m "integration and not installed"


test-installed:
	pytest -m "installed" --shell=bash --shell=zsh


html:
	cd docs && make html


.PHONY: $(MAKECMDGOALS)
