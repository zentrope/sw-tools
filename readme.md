# sw-tools

## Rationale

Sw-tools is a small project for writing tiny command line tools in
Swift. Although I actually use these tools, this repo is mainly for
learning. Some implementations will be more complicated than necessary
as a proxy for (eventually) writing more complicated services in
Swift.

## Tools

Implemented so far:

- **uuid**: <br/>Print out one or more randomly generated UUIDs.

- **webdev**:<br/> Serve a directory as a website, if 404, reload
index.html (good for react-router or similar).

## Usage

Check out the project, then:

    $ swift package update
    $ make release

and copy the executabe files in `.build/release` to a place on your
`$PATH`:

    $ cp .build/release/uuid ~/Bin
    $ cp .build/release/webdev ~/Bin

If you want to reduce the size of the binaries:

    $ strip ~/Bin/uuid
    $ strip ~/Bin/webdev

Each utility has a `-h` and `--help` option for details.

## License

Copyright (c) 2018-present Keith Irwin

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see
[http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).
