all: first compile middle exec end clean

compile:
	g++ -fPIC -shared example.cpp -o example.so

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
