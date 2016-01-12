# Analyzing a rails project

* Start process
* Do couple of requests (for getting normal heap)
* Get a heap dump
* Do a bunch more requests
* Get a heap dump
* Analyze differences

## Getting a heap dump

in development.rb:

    cache_classes: true
    eager_load: true
    perform_caching: true

in initializers/profiling.rb

    require 'objspace'
    ObjectSpace.trace_object_allocations_start

newrelic.yml

    developer_mode: false

in test controller

    def dump_heap
      GC.start; io=File.open((Rails.root + "tmp/ruby-heap.dump").to_s, "w"); ObjectSpace.dump_all(output: io); io.close
    end

in routes

    get 'test/dump_heap', to: 'test#dump_heap'

## Analyzing with this thing

* Differ shows differences (leaked objects) between 2 heap dumps
* Analyze allows you to look at a heap dump in detail. Look for objects that are not in the first couple of generations, but also not in the last. Example generation_count_report: 

````
1 233
2 3223
3 33
4 1
5 1
6 1
7 1
9 233
````

In this case the objects in 4,5,6,7 might be leaked

## More info:
* https://gist.github.com/r38y/02f4378a19f9064d2da2
* http://samsaffron.com/archive/2015/03/31/debugging-memory-leaks-in-ruby
