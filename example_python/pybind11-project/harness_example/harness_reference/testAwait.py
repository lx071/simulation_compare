from collections.abc import Awaitable
import asyncio
# 需要导入模块: from collections import abc [as 别名]

# 或者: from collections.abc import Awaitable [as 别名]


class Trigger(Awaitable):
    """Base class to derive from."""

    def __init__(self):
        self.primed = False

    def __await__(self):
        # hand the trigger back to the scheduler trampoline
        # return (yield self)
        print("222")
        return (yield)


async def s():
    await Trigger()


if __name__ == '__main__':
    asyncio.run(s())
    pass
