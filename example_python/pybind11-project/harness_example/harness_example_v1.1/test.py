import example
p = example.getHandle('value')
for i in range(5):
    value = example.getValue(p, i)
    print(value)
example.setValue(p, 0, 11)
value = example.getValue(p, 0)
print(value)
example.eval(p)

# <example.Pet object at 0x7fd6dbb5cf30>
# Molly
# Charly
