import numpy
from matplotlib import pyplot

CONV_CORE_DEPTH = 256
SAMPLE_RATE = 100*1e6
LOWPASS_FREQ = 5*1e6
HIGHPASS_FREQ = 10*1e6


def main():
    fdomin_array = numpy.zeros(int(CONV_CORE_DEPTH/2+1))
    for i in numpy.arange(int(CONV_CORE_DEPTH*(LOWPASS_FREQ/SAMPLE_RATE)), int(CONV_CORE_DEPTH*(HIGHPASS_FREQ/SAMPLE_RATE))):
        fdomin_array[i] = 100

    conv_core = numpy.fft.irfft(fdomin_array)
    print("Length:", len(conv_core))
    print("FIR summary:", sum(conv_core))

    for i in range(int(CONV_CORE_DEPTH/2)):
        tmp = conv_core[i]
        conv_core[i] = conv_core[int(CONV_CORE_DEPTH/2)+i]
        conv_core[int(CONV_CORE_DEPTH/2)+i] = tmp

    conv_core -= min(conv_core)
    conv_core *= 4096/sum(conv_core)

    pyplot.plot(fdomin_array)
    pyplot.plot(conv_core)
    pyplot.show()

    print("FIR summary:", sum(conv_core))

    with open("conv_core.dat", "w") as f:
        for i in conv_core:
            f.write("{:04x}\n".format(int(i)))

    return 0


if __name__ == "__main__":
    main()
