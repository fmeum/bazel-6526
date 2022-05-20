#include <fstream>
#include <iostream>
#include <string>

#include "tools/cpp/runfiles/runfiles.h"

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << "OUT_FILE" << std::endl;
    exit(1);
  }

  using bazel::tools::cpp::runfiles::Runfiles;
  std::string error;
  Runfiles* runfiles = Runfiles::Create(argv[0], &error);
  if (runfiles == nullptr) {
    std::cerr << "Failed to initialize runfile lookup: " << error << std::endl;
    exit(1);
  }
  std::string version_file = runfiles->Rlocation("path_mapping_example/tools/version.txt");

  std::ifstream src(version_file);
  if (!src.good()) {
    std::cerr << "Failed to find runfile at: " << version_file << std::endl;
    exit(1);
  }
  std::ofstream dst(argv[1]);
  dst << src.rdbuf();
}