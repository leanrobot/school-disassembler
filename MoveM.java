public class MoveM {

	public static void main(String[] args) {
		byte[][] b = {
			{1,1,1,1,1,1,1,1},	// D0-D7 		
			{1,0,0,0,0,0,0,0},	// D0
			{1,1,0,0,0,0,0,0},	// D0-D1
			{0,0,0,0,0,0,0,1},	// D7
			{0,0,0,0,0,0,1,1},	// D6-D7
			{1,1,0,0,0,0,1,1},	// D0-D1/D6-D7
			{0,0,0,1,1,1,0,0},	// D3-D5		
			{0,1,1,0,1,0,0,1}, 	// D1-D2/D4/D7
			{0,1,1,1,1,1,1,0},	// D1-D6
			{1,1,1,0,1,0,1,1},	// D0-D2/D4/D6-D7
			{1,0,1,0,1,0,1,0},	// D0/D2/D4/D6
			{0,1,0,1,0,1,0,1}	// D1/D3/D5/D7
		};

		for(int i=0; i < b.length; i++) {
			printRegList(b[i], 0, b[i].length);
		}



		
		/*
		if(last == 1) {
			if(list) System.out.print("-");
			System.out.print("D"+(b.length-1));
		}
		System.out.println();
		*/
	}

	public static void printRegList(int pop, 
					byte[] byte1, byte[] byte2) {
		if(pop == 1) {
			printModular(byte1, 7, 0, -1, 'A');
			printModular(byte2, 7, 0, -1, 'D');
		}

	}

	public static boolean notZero(byte[] b) {
		for(int i=0;i<b.length; i++) {
			if(b[i] == 1) return false;
		}
		return true;
	}

	public static void printModular(byte[] b, 
						int start, int end, int dr, 
						char ch) {
		int list = 0;
		int first = 1;
		int last = 0;
		int i = start;
		while(i < end) {
			int cur = b[i];
			if(cur == 1 && last == 0) { 		// 01
				if(first == 0) 
					System.out.print("/");
				System.out.print(ch+i);
				first = 0;
			}
			else if(last == 1 && cur == 1) { 	// 11
				list = 1;
			}
			else if(last == 1 && cur == 0) {	// 10
				if(list == 1)
					System.out.print("-"+ch+(i-1));
				list = 0;
			}
			last = cur;
			i++;
		}
		if(list == 1) 
			System.out.print("-"+ch+(end-1));
		System.out.println();
	}
}