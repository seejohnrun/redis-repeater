## Redis Repeater

Constantly transfer all Redis items from one queue to the same queue on another machine.
Great if you want to have multiple Resque machines, but only want the jobs to run on one of them.  With Resque Repeater, you temporarily _stage_ them on local machines so your application doesn't need to make calls across the world.

### Configuration

**config/queues.yml** - Set queue names to transfer with timeouts (0 if none)

    queue:john: 4
    some_other_queue: 5
    listings: 0

**config/config.yml** - What machines?

    origin:
        host: localhost
        port: 6379

    destination:
        host: some.production_box.example.com
        port: 6380

		log: /path/to/repeater.log

### Dependencies

* Event Machine

### Author

* John Crepezzi - john.crepezzi@patch.com

### Issues?

* Use the built-in Github issue tracker

### Contributing

* Contributions are welcome - I use Lighthouse for bug fixes (accompanying failing tests are awesome) and feature requests
* Submit via fork and pull request (include tests)
* Stick with my code style, and don’t get mad if I make style changes to your code (consistency is a key to readability)
* If you’re working on something major, shoot me a message beforehand

### License

(The MIT License)

Copyright © 2010 John Crepezzi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE
