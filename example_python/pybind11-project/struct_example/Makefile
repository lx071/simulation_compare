all: first compile middle exec end clean

compile:
	c++ -O3 -Wall -shared -std=c++11 -fPIC $(shell python3 -m pybind11 --includes) example.cpp -o example$(shell python3-config --extension-suffix)

exec:
	python test.py

first:
	date +%M.%s.%N

middle:
	date +%M.%s.%N

end:
	date +%M.%s.%N

clean:
	-rm -f *.so


	
