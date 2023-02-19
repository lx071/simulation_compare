
def join(data_package):
    item_bit_width = data_package.item_bit_width
    data = data_package.data
    res = 0
    for i in range(len(data)):
        for j in range(len(item_bit_width)):
            res = (res << item_bit_width[j]) + data[i][j]
        pass
    return res
