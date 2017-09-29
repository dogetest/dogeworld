Dogecoin mod connects minetest to a dogecoin node's JSONRPC API
using a modified version of jsonrpc4lua which works with
minetest http api instead of luasockets.
SSL isnt supported.
Depends on jsonrpc4minetestlua mod.
Needs a full dogecoin node up and synced,running as daemon and
the user and password must be set in minetest.conf as below:

Required config:

    doge.rpcuser=<rpcuser>
    doge.rpcpassword=<rpcpassword>

Optional:

    doge.rpcport=<rpcport> (deafult:44555(testnet))
    doge.rpcaddress=<rpcaddress> (deafult:127.0.0.1)

It also implements some features:
dogecoin.url
dogecoin.transfer(from, to, amount, reason)

Advanced usage:

    local proxy=rpc.proxy(dogecoin.url, function(res)
      minetest.debug(dump(res))
      end)
    proxy.listaccounts()
