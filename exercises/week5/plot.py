import matplotlib.pyplot as plt


def plot():
    threads = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8
    ]

    total_flops = 23525785610.0 / 1000000000.0
    times = [
      7.472842,
      3.742960,
      4.568976,
      3.105185,
      3.075989,
      2.811607,
      2.640582,
      2.536771
    ]

    gflops = [total_flops / t for t in times]

    plt.figure()
    plt.bar(threads, gflops)
    plt.xlabel('threads')
    plt.ylabel('GFLOPS')
    plt.title('SaC Mandelbrot benchmark')
    plt.savefig("sac-mandelbrot-bench.png")
    plt.close()


if __name__ == '__main__':
  plot()
