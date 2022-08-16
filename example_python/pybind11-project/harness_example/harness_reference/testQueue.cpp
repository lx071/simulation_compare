#include <queue>
#include <iostream>
using namespace std;

queue<int> q;

int main(){
	for (int i = 0; i < 10; i++){
		q.push(i);
	}
	if (!q.empty()){
		cout << "队列q非空！" << endl;
		cout << "q中有" << q.size() << "个元素" << endl;
	}
	cout << "队头元素为：" << q.front() << endl;
	cout << "队尾元素为：" << q.back() << endl;
	for (int j = 0; j < 10; j++){
		int tmp = q.front();
		cout << tmp << " ";
		q.pop();
	}
	cout << endl;
	if (!q.empty()){
		cout << "队列非空！" << endl;
	}
	system("pause");
	return 0;
}