import numpy
from matplotlib import pyplot

CONV_CORE_DEPTH = 256

def main():
    conv_core = numpy.ones(CONV_CORE_DEPTH)
    with open("conv_core.dat", "w") as f:
        for i in conv_core:
            f.write("{:04x}\n".format(int(i)))

    return 0


if __name__ == "__main__":
    main()
