import numpy
from matplotlib import pyplot

CONV_CORE_DEPTH = 256
SAMPLE_RATE = 100*1e6


def main():
    orgin_res = []
    with open("../orgin_res.dat", "r") as f:
        r_lines = f.readlines()
        for i in r_lines:
            orgin_res.append(int(i))
    orgin_res -= numpy.average(orgin_res)

    proc_res = []
    with open("../proc_res.dat", "r") as f:
        r_lines = f.readlines()
        for i in r_lines:
            proc_res.append(int(i))
    proc_res -= numpy.average(proc_res)

    orgin_res_vpp = max(orgin_res)-min(orgin_res)
    proc_res_vpp = max(proc_res)-min(proc_res)
    orgin_res *= proc_res_vpp/orgin_res_vpp

    pyplot.plot(orgin_res)
    pyplot.plot(proc_res)
    pyplot.show()

    orgin_res_rfft = numpy.fft.rfft(orgin_res[:1024])
    proc_res_rfft = numpy.fft.rfft(proc_res[:1024])

    pyplot.plot(numpy.log10(orgin_res_rfft[1:]))
    pyplot.plot(numpy.log10(proc_res_rfft[1:]))
    pyplot.show()

    return 0


if __name__ == "__main__":
    main()
