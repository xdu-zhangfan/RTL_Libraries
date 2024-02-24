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

    orgin_res_fft = numpy.fft.fft(orgin_res[:1000])
    proc_res_fft = numpy.fft.fft(proc_res[:1000])

    orgin_res_fft_amp = numpy.abs(orgin_res_fft)
    orgin_res_fft_phase = numpy.arctan(- numpy.imag(orgin_res_fft) /
                                       numpy.real(orgin_res_fft))
    print(orgin_res_fft_phase)

    proc_res_fft_amp = numpy.abs(proc_res_fft)
    proc_res_fft_phase = numpy.arctan(-numpy.imag(
        proc_res_fft)/numpy.real(proc_res_fft))

    pyplot.plot(numpy.log10(orgin_res_fft_amp))
    pyplot.plot(numpy.log10(proc_res_fft_amp))
    pyplot.show()

    pyplot.plot(orgin_res_fft_phase)
    pyplot.plot(proc_res_fft_phase)
    pyplot.show()

    return 0


if __name__ == "__main__":
    main()
