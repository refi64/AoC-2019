// Implemented via C++20 ranges.

#include <range/v3/range.hpp>
#include <range/v3/algorithm/copy.hpp>
#include <range/v3/iterator/insert_iterators.hpp>
#include <range/v3/iterator/stream_iterators.hpp>
#include <range/v3/numeric/accumulate.hpp>
#include <range/v3/view/drop.hpp>
#include <range/v3/view/exclusive_scan.hpp>
#include <range/v3/view/iota.hpp>
#include <range/v3/view/istream.hpp>
#include <range/v3/view/take_while.hpp>
#include <range/v3/view/transform.hpp>

#include <fstream>
#include <functional>
#include <iostream>

template <typename Pred, typename Func, typename Value>
auto scan_while(Pred pred, Func func, Value init) {
  return ranges::views::ints(0, ranges::unreachable)
          | ranges::views::exclusive_scan(init, std::bind(func, std::placeholders::_1))
          | ranges::views::take_while(pred);
}

int get_fuel(int mass) { return std::max(mass / 3 - 2, 0); }

std::vector<int> load_modules() {
  std::ifstream input("input");
  if (!input) {
    throw std::runtime_error("failed to open input");
  }

  return ranges::to<std::vector<int>>(ranges::istream_view<int>(input));
}

void part1(const std::vector<int>& modules) {
  int fuel = ranges::accumulate(modules | ranges::views::transform(get_fuel), 0);
  std::cout << "part 1: " << fuel << std::endl;
}

void part2(const std::vector<int>& modules) {
  int fuel = ranges::accumulate(
    modules
      | ranges::views::transform([](int mass) {
        return ranges::accumulate(
          scan_while([](int fuel) { return fuel != 0; }, get_fuel, mass) | ranges::views::drop(1),
          0);
        }),
    0
  );

  std::cout << "part 2: " << fuel << std::endl;
}

int main() {
  auto modules = load_modules();

  part1(modules);
  part2(modules);

  return 0;
}
