#------------------------------------------------------------------------------
# Copyright (c) 2018-present Keith Irwin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
#------------------------------------------------------------------------------
# This Makefile is a launcher more than a maker.
#------------------------------------------------------------------------------

.PHONY: clean build release
.DEFAULT_GOAL := help

clean:
	swift package clean

build:
	swift build

release:
	swift build -c release --static-swift-stdlib

test:
	swift test

help: ## Show makefile based help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}' \
		| sort
