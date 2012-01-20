# test init module

define 'test','load_test_1','load_test_2',(exports,test1,test2) ->
  $ ->
    test1.test_func()

