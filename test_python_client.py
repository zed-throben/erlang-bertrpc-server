# easy_install bertrpc

import bertrpc
service = bertrpc.Service('127.0.0.1', 9999)

response = service.request('call').lists.reverse( [1, 2,3] )
print( response )
