//
//  UMRedisCommand.m
//  ulib
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//

#import "UMRedisCommand.h"

@implementation UMRedisCommand

+ (NSString *)commandName:(UMRedisCommandCode)code
{
    switch(code)
    {
        case REDIS_APPEND:
            return @"APPEND";
        case REDIS_AUTH:
            return @"AUTH";
        case REDIS_BGREWRITEAOF:
            return @"BGREWRITEAOF";
        case REDIS_BGSAVE:
            return @"BGSAVE";
        case REDIS_BITCOUNT:
            return @"BITCOUNT";
        case REDIS_BITOP:
            return @"BITOP";
        case REDIS_BITPOS:
            return @"BITPOS";
        case REDIS_BLPOP:
            return @"BLPOP";
        case REDIS_BRPOP:
            return @"BRPOP";
        case REDIS_BRPOPLPUSH:
            return @"BRPOPLPUSH";
        case REDIS_CLIENT_KILL:
            return @"CLIENT_KILL";
        case REDIS_CLIENT_LIST:
            return @"CLIENT_LIST";
        case REDIS_CLIENT_GETNAME:
            return @"CLIENT_GETNAME";
        case REDIS_CLIENT_PAUSE:
            return @"CLIENT_PAUSE";
        case REDIS_CLIENT_SETNAME:
            return @"CLIENT_SETNAME";
        case REDIS_CONFIG_GET:
            return @"CONFIG_GET";
        case REDIS_CONFIG_REWRITE:
            return @"CONFIG_REWRITE";
        case REDIS_CONFIG_SET:
            return @"CONFIG_SET";
        case REDIS_CONFIG_RESETSTAT:
            return @"CONFIG_RESETSTAT";
        case REDIS_DBSIZE:
            return @"DBSIZE";
        case REDIS_DEBUG_OBJECT:
            return @"DEBUG_OBJECT";
        case REDIS_DEBUG_SEGFAULT:
            return @"DEBUG_SEGFAULT";
        case REDIS_DECR:
            return @"DECR";
        case REDIS_DECRBY:
            return @"DECRBY";
        case REDIS_DEL:
            return @"DEL";
        case REDIS_DISCARD:
            return @"DISCARD";
        case REDIS_DUMP:
            return @"DUMP";
        case REDIS_ECHO:
            return @"ECHO";
        case REDIS_EVAL:
            return @"EVAL";
        case REDIS_EVALSHA:
            return @"EVALSHA";
        case REDIS_EXEC:
            return @"EXEC";
        case REDIS_EXISTS:
            return @"EXISTS";
        case REDIS_EXPIRE:
            return @"EXPIRE";
        case REDIS_EXPIREAT:
            return @"EXPIREAT";
        case REDIS_FLUSHALL:
            return @"FLUSHALL";
        case REDIS_FLUSHDB:
            return @"FLUSHDB";
        case REDIS_GET:
            return @"GET";
        case REDIS_GETBIT:
            return @"GETBIT";
        case REDIS_GETRANGE:
            return @"GETRANGE";
        case REDIS_GETSET:
            return @"GETSET";
        case REDIS_HDEL:
            return @"HDEL";
        case REDIS_HEXISTS:
            return @"HEXISTS";
        case REDIS_HGET:
            return @"HGET";
        case REDIS_HGETALL:
            return @"HGETALL";
        case REDIS_HINCRBY:
            return @"HINCRBY";
        case REDIS_HINCRBYFLOAT:
            return @"HINCRBYFLOAT";
        case REDIS_HKEYS:
            return @"HKEYS";
        case REDIS_HLEN:
            return @"HLEN";
        case REDIS_HMGET:
            return @"HMGET";
        case REDIS_HMSET:
            return @"HMSET";
        case REDIS_HSET:
            return @"HSET";
        case REDIS_HSETNX:
            return @"HSETNX";
        case REDIS_HVALS:
            return @"HVALS";
        case REDIS_INCR:
            return @"INCR";
        case REDIS_INCRBY:
            return @"INCRBY";
        case REDIS_INCRBYFLOAT:
            return @"INCRBYFLOAT";
        case REDIS_INFO:
            return @"INFO";
        case REDIS_KEYS:
            return @"KEYS";
        case REDIS_LASTSAVE:
            return @"LASTSAVE";
        case REDIS_LINDEX:
            return @"LINDEX";
        case REDIS_LINSERT:
            return @"LINSERT";
        case REDIS_LLEN:
            return @"LLEN";
        case REDIS_LPOP:
            return @"LPOP";
        case REDIS_LPUSH:
            return @"LPUSH";
        case REDIS_LPUSHX:
            return @"LPUSHX";
        case REDIS_LRANGE:
            return @"LRANGE";
        case REDIS_LREM:
            return @"LREM";
        case REDIS_LSET:
            return @"LSET";
        case REDIS_LTRIM:
            return @"LTRIM";
        case REDIS_MGET:
            return @"MGET";
        case REDIS_MIGRATE:
            return @"MIGRATE";
        case REDIS_MONITOR:
            return @"MONITOR";
        case REDIS_MOVE:
            return @"MOVE";
        case REDIS_MSET:
            return @"MSET";
        case REDIS_MSETNX:
            return @"MSETNX";
        case REDIS_MULTI:
            return @"MULTI";
        case REDIS_OBJECT:
            return @"OBJECT";
        case REDIS_PERSIST:
            return @"PERSIST";
        case REDIS_PEXPIRE:
            return @"PEXPIRE";
        case REDIS_PEXPIREAT:
            return @"PEXPIREAT";
        case REDIS_PFADD:
            return @"PFADD";
        case REDIS_PFCOUNT:
            return @"PFCOUNT";
        case REDIS_PFMERGE:
            return @"PFMERGE";
        case REDIS_PING:
            return @"PING";
        case REDIS_PSETEX:
            return @"PSETEX";
        case REDIS_PSUBSCRIBE:
            return @"PSUBSCRIBE";
        case REDIS_PUBSUB:
            return @"PUBSUB";
        case REDIS_PTTL:
            return @"PTTL";
        case REDIS_PUBLISH:
            return @"PUBLISH";
        case REDIS_PUNSUBSCRIBE:
            return @"PUNSUBSCRIBE";
        case REDIS_QUIT:
            return @"QUIT";
        case REDIS_RANDOMKEY:
            return @"RANDOMKEY";
        case REDIS_RENAME:
            return @"RENAME";
        case REDIS_RENAMENX:
            return @"RENAMENX";
        case REDIS_RESTORE:
            return @"RESTORE";
        case REDIS_RPOP:
            return @"RPOP";
        case REDIS_RPOPLPUSH:
            return @"RPOPLPUSH";
        case REDIS_RPUSH:
            return @"RPUSH";
        case REDIS_RPUSHX:
            return @"RPUSHX";
        case REDIS_SADD:
            return @"SADD";
        case REDIS_SAVE:
            return @"SAVE";
        case REDIS_SCARD:
            return @"SCARD";
        case REDIS_SCRIPT_EXISTS:
            return @"SCRIPT_EXISTS";
        case REDIS_SCRIPT_FLUSH:
            return @"SCRIPT_FLUSH";
        case REDIS_SCRIPT_KILL:
            return @"SCRIPT_KILL";
        case REDIS_SCRIPT_LOAD:
            return @"SCRIPT_LOAD";
        case REDIS_SDIFF:
            return @"SDIFF";
        case REDIS_SDIFFSTORE:
            return @"SDIFFSTORE";
        case REDIS_SELECT:
            return @"SELECT";
        case REDIS_SET:
            return @"SET";
        case REDIS_SETBIT:
            return @"SETBIT";
        case REDIS_SETEX:
            return @"SETEX";
        case REDIS_SETNX:
            return @"SETNX";
        case REDIS_SETRANGE:
            return @"SETRANGE";
        case REDIS_SHUTDOWN_NOSAVE:
            return @"SHUTDOWN_NOSAVE";
        case REDIS_SHUTDOWN_SAVE:
            return @"SHUTDOWN_SAVE";
        case REDIS_SINTER:
            return @"SINTER";
        case REDIS_SINTERSTORE:
            return @"SINTERSTORE";
        case REDIS_SISMEMBER:
            return @"SISMEMBER";
        case REDIS_SLAVEOF:
            return @"SLAVEOF";
        case REDIS_SLOWLOG:
            return @"SLOWLOG";
        case REDIS_SMEMBERS:
            return @"SMEMBERS";
        case REDIS_SMOVE:
            return @"SMOVE";
        case REDIS_SORT:
            return @"SORT";
        case REDIS_SPOP:
            return @"SPOP";
        case REDIS_SRANDMEMBER:
            return @"SRANDMEMBER";
        case REDIS_SREM:
            return @"SREM";
        case REDIS_STRLEN:
            return @"STRLEN";
        case REDIS_SUBSCRIBE:
            return @"SUBSCRIBE";
        case REDIS_SUNION:
            return @"SUNION";
        case REDIS_SUNIONSTORE:
            return @"SUNIONSTORE";
        case REDIS_SYNC:
            return @"SYNC";
        case REDIS_TIME:
            return @"TIME";
        case REDIS_TTL:
            return @"TTL";
        case REDIS_TYPE:
            return @"TYPE";
        case REDIS_UNSUBSCRIBE:
            return @"UNSUBSCRIBE";
        case REDIS_UNWATCH:
            return @"UNWATCH";
        case REDIS_WATCH:
            return @"WATCH";
        case REDIS_ZADD:
            return @"ZADD";
        case REDIS_ZCARD:
            return @"ZCARD";
        case REDIS_ZCOUNT:
            return @"ZCOUNT";
        case REDIS_ZINCRBY:
            return @"ZINCRBY";
        case REDIS_ZINTERSTORE:
            return @"ZINTERSTORE";
        case REDIS_ZLEXCOUNT:
            return @"ZLEXCOUNT";
        case REDIS_ZRANGE:
            return @"ZRANGE";
        case REDIS_ZRANGEBYLEX:
            return @"ZRANGEBYLEX";
        case REDIS_ZRANGEBYSCORE:
            return @"ZRANGEBYSCORE";
        case REDIS_ZRANK:
            return @"ZRANK";
        case REDIS_ZREM:
            return @"ZREM";
        case REDIS_ZREMRANGEBYLEX:
            return @"ZREMRANGEBYLEX";
        case REDIS_ZREMRANGEBYRANK:
            return @"ZREMRANGEBYRANK";
        case REDIS_ZREMRANGEBYSCORE:
            return @"ZREMRANGEBYSCORE";
        case REDIS_ZREVRANGE:
            return @"ZREVRANGE";
        case REDIS_ZREVRANGEBYSCORE:
            return @"ZREVRANGEBYSCORE";
        case REDIS_ZREVRANK:
            return @"ZREVRANK";
        case REDIS_ZSCORE:
            return @"ZSCORE";
        case REDIS_ZUNIONSTORE:
            return @"ZUNIONSTORE";
        case REDIS_SCAN:
            return @"SCAN";
        case REDIS_SSCAN:
            return @"SSCAN";
        case REDIS_HSCAN:
            return @"HSCAN";
        case REDIS_ZSCAN:
            return @"ZSCAN";
        return @"undefined";
    }
}


@end

