import numpy as np
import sys


def main():
    if (len(sys.argv)) != 3:
        print("Usage: python gen_cos_data.py depth_bitwidth data_bitwidth")
        quit()

    depth_bitwidth = int(sys.argv[1])
    data_bitwidth = int(sys.argv[2])
    file_x1_name = "cos_data_x1.dat"
    file_x4_name = "cos_data_x4.dat"

    depth = 2**depth_bitwidth

    cos_data = []
    for i in np.arange(depth):
        value = np.cos(2*np.pi/depth*i)+1
        cos_data.append(value * (2**(data_bitwidth-1)))

    with open(file_x1_name, "w") as f_x1:
        str_format = "{:0" + str(int(data_bitwidth/4)) + "X}\n"

        for i in range(int(len(cos_data)/4)):
            if (cos_data[i] == 2**data_bitwidth):
                f_x1.write(str_format.format(2**data_bitwidth-1))
            else:
                f_x1.write(str_format.format(int(cos_data[i])))

    with open(file_x4_name, "w") as f_x4:
        str_format = "{:0" + str(int(data_bitwidth/4)) + "X}\n"

        for i in range(len(cos_data)):
            if (cos_data[i] == 2**data_bitwidth):
                f_x4.write(str_format.format(2**data_bitwidth-1))
            else:
                f_x4.write(str_format.format(int(cos_data[i])))


if __name__ == "__main__":
    main()
