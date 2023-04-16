//main.h
#ifndef __MAIN_H
#define __MAIN_H

#include <systemc.h>
SC_MODULE(hello){
	SC_CTOR(hello){
		cout << "constructor of hello" << endl;
	}
	void say_hello(void){
		cout << "Say hello" << endl;
	}
};

#endif
