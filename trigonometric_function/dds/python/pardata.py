import numpy
from matplotlib import pyplot

CONV_CORE_DEPTH = 256
SAMPLE_RATE = 100*1e6


def main():
    res = []
    with open("../res.dat", "r") as f:
        r_lines = f.readlines()
        for i in r_lines:
            res.append(int(i))
    res -= numpy.average(res)

    res_fft = numpy.fft.rfft(res)
    res_fft[0] = res_fft[1]

    pyplot.plot(numpy.log10(res_fft))
    pyplot.show()

    return 0


if __name__ == "__main__":
    main()
