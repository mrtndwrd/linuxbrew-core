class Pagmo < Formula
  desc "Scientific library for massively parallel optimization"
  homepage "https://esa.github.io/pagmo2/"
  url "https://github.com/esa/pagmo2/archive/v2.10.tar.gz"
  sha256 "2fa95e2b464ddeadb9fc09bd314081293f02a1b6abc11c0b05064729a077227c"

  bottle do
    cellar :any_skip_relocation
    sha256 "11a158a55b100b182c49807d68d5400ca55d98011535b4d923f1ee232f58a9b0" => :mojave
    sha256 "2c8e09c8e42c16f36f4c5b4fa82b465402fd6b50e5c55e9b4befdae04636a5fc" => :high_sierra
    sha256 "2c8e09c8e42c16f36f4c5b4fa82b465402fd6b50e5c55e9b4befdae04636a5fc" => :sierra
    sha256 "332e3d96d1c4820eb67499712d42010f8870f1b5c144d836af75ec30fe202370" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "eigen"
  depends_on "nlopt"

  def install
    ENV.cxx11
    system "cmake", ".", "-DPAGMO_WITH_EIGEN3=ON", "-DPAGMO_WITH_NLOPT=ON",
                         *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>

      #include <pagmo/algorithm.hpp>
      #include <pagmo/algorithms/sade.hpp>
      #include <pagmo/archipelago.hpp>
      #include <pagmo/problem.hpp>
      #include <pagmo/problems/schwefel.hpp>

      using namespace pagmo;

      int main()
      {
          // 1 - Instantiate a pagmo problem constructing it from a UDP
          // (user defined problem).
          problem prob{schwefel(30)};

          // 2 - Instantiate a pagmo algorithm
          algorithm algo{sade(100)};

          // 3 - Instantiate an archipelago with 16 islands having each 20 individuals
          archipelago archi{16, algo, prob, 20};

          // 4 - Run the evolution in parallel on the 16 separate islands 10 times.
          archi.evolve(10);

          // 5 - Wait for the evolutions to be finished
          archi.wait_check();

          // 6 - Print the fitness of the best solution in each island
          for (const auto &isl : archi) {
              std::cout << isl.get_population().champion_f()[0] << std::endl;
          }

          return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{Formula["eigen"].include}/eigen3",
                    "-I#{include}", "-std=c++11", *("-pthread" unless OS.mac?),
                    "-o", "test"
    system "./test"
  end
end
