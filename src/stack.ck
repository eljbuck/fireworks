// name: queue.ck
// ===============
// author: Ethan Buck
// date: 11/27/23
//
// desc: very basic implementation of queue data structure (very easy with ChucK arrays haha)
//
// note 1: I do not know how to return null in chuck, so if dequeue() or peek() is called on an 
// empty array, then the dummy_return value is returned.
// 
// note 2: you have to manually change the types (e.g. replace all int declarations with whatever
// type you want, except for the front and rear pointers!!) for whatever type you are using :(
public class GMeshStack {
    GMesh stack[0];
    // 0 => int front => int rear;     // don't change these types!!
    GMesh dummy_return;   // returns if dequeue() or peek() called on an empty queue

    fun int isEmpty() {
        return stack.size() == 0;
    }

    // insert element to rear of queue
    fun void push(GMesh @x) {
        stack << x;
    }

    fun GMesh pop() {
        if (this.isEmpty()) {
            <<< "stack is empty, nothing to dequeue" >>>;
            return dummy_return;
        } else {
            // 1 -=> rear;
            stack[stack.size() - 1] @=> GMesh @output;
            stack.popBack();
            return output;
        }
    }

    fun GMesh peek() {
        if (this.isEmpty()) {
            <<< "stack is empty, nothing to peek" >>>;
            return dummy_return;
        } else {
            return stack[stack.size() - 1];
        }
    }

    fun int size() {
        return stack.size();
    }

    fun void display() {
        if (this.isEmpty()) {
            <<< "stack is empty, nothing to display" >>>;
        } else {
            for (0 => int i; i < stack.size(); 1 +=> i) {
                <<<"stack[", i, "] = ", stack[i] >>>; 
            }
        }
    }
}