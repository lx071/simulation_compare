import example
p = example.Pet("Molly")
print(p)
name = p.getName()
print(name)
p.setName("Charly")
name = p.getName()
print(name)
print(p.name)
# <example.Pet object at 0x7f26fd4a50f0>
# Molly
# Charly
# Charly
