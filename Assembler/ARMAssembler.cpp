#include <iostream>
#include <string>
#include <fstream>
#include <bitset>

std::ifstream infile("input.txt");

using namespace std;

int main()
{
     const string CMD [27][2] = { {"AND", "EOR", "SUB", "RSB", "ADD", "ADC", "SBC", "RSC", "TST", "TEQ", "CMP", "CMN", "ORR", "BIC", "MVN", "MOV", "LSL", "LSR", "ASR", "RRX", "ROR", "MUL", "MLA", "UMULL", "UMLAL", "SMULL", "SMLAL"}, {"0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010", "1011", "1100", "1110", "1111", "1101", "1101", "1101", "1101", "1101", "1101", "0 000", "0 001", "0 100", "0 101", "0 110", "0 111"} };
     const string ST [4][2] = { {"LSL", "LSR", "ASR", "ROR"}, {"00", "01", "10", "11"} };
     const string MEM[4] = {"LDR", "STR", "LDRB", "STRB"};
     const string R1 [10][2] = { {"R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10"}, {"0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010"} };
     const string R2 [10][2] = { {"R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10"}, {"0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010"} };
     const string R3 [10][2] = { {"R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10"}, {"0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010"} };
     const string R4 [10][2] = { {"R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10"}, {"0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001", "1010"} };
    
     string cond = "0000";
     string cmd = "0";
	string op = "0";
	string s = "0";
	string i = "0";
	string rn = "0000";
	string rd = "0000";
	string rot = "0000";
	string imm8 = "00000000";
	string shamt5 = "0000";
	string sh = "00";
	string rm = "0000";
	string rs = "0000";
	string p = "0";
	string u = "0";
	string b = "0";
	string w = "0";
	string l = "0";
	string imm12 = "000000000000";
	string il = "00";
	string imm24 "000000000000000000000000";
	string lb = "0";
     string pc = "0000";
     
     bool MEM = false;
     bool i_set = false;
    
     cout << "Reading file." << endl << endl;
    
     while (infile >> a >> b >> c >> d >> e >> f)
     {
		
		//determine cmd and a few other bits from read in file
          for (z = 0; z <= 26; z++)
          {
               if (a == CMD[z][1])
               {
                    cmd = CMD[z][2];
				
				op = "00";
				
				if (z == 8 | 9 | 10 | 11)
				{
					s = "1";
				}
				else if (z == 15)
				{
					i = "1";
				}
				else if (z == 16)
				{
					i = "0";
					sh = "00";
				}
				else if (z == 17)
				{
					i = "0";
					sh = "01";
				}
				else if (z == 18)
				{
					i = "0";
					sh "10";
				}
				else if (z == 19)
				{
					i = "0";
					sh = "11";
					instr = "00000000";	
				}
				else if (z == 20)
				{
					i = "0";
					sh = "11";
				}
				
                    z = 26;
               }
          }
		

          if (a == MEM[0] || a == MEM[2])
          {
               op = "01";
               MEM = true;
               
               if (f.at(0) == "#")
               {
                    i = "0";
                    if (f.at(1) == "-")
                    {
                         u = "0";
                         f.erase(0);
                         f.erase(1);
                    }
                    else
                    {
                         u = "1";
                         f.erase(0);
                    }
                    
                    p = "0";
                    b = "0";
                    w = "0";
                    l = "0";
               }
               else if
               {
                    for (z = 0; z <= 3; z++)
                    {
                         if (d == R3[z][1])
                         {
                              i = "1";
                              rm = R3[z][2];
                              shamt5 = "0000";
                              sh = "0";
                              p = "1";
                              u = "1";
                              b = "0";
                              w = "0";
                              l = "0";
                              z = 3;
                         }
                    }
               }
               
               if (i=="0")
               {
                    imm12 = f;
                    imm12 = std::string binary = std::bitset<12>(imm12).to_string();
               }
          }
          else if (a == MEM[1] || a == MEM[3])
          {
               op = "01";
               MEM = true;
               
               if (f.at(0) == "#")
               {
                    i = "0";
                    if (f.at(1) == "-")
                    {
                         u = "0";
                         f.erase(0);
                         f.erase(1);
                    }
                    else
                    {
                         u = "1";
                         f.erase(0);
                    }
                    
                    p = "0";
                    b = "0";
                    w = "0";
                    l = "1";
               }
               else if
               {
                    for (z = 0; z <= 3; z++)
                    {
                         if (d == R3[z][1])
                         {
                              i = "1";
                              rm = R3[z][2];
                              shamt5 = "0000";
                              sh = "0";
                              p = "1";
                              u = "1";
                              b = "0";
                              w = "0";
                              l = "1";
                              z = 3;
                         }
                    }
               }
               
               if (i=="0")
               {
                    imm12 = f;
                    imm12 = std::string binary = std::bitset<12>(imm12).to_string();
               }
          }
          
		cond = "1110";
          
          if (a == "L")
          {
               op = "10";
               il = "0";
               pc = "1100";
               
               imm24 = std::string binary = std::bitset<24>(pc).to_string();
          }
          else if (a == "BL")
          {
               op = "10";
               il = "1":
               pc = "0011";
               
               imm24 = std::string binary = std::bitset<24>(pc).to_string();
          }
		
		//determine and set rn and rd from read in values
          if(MEM == false)
          {
               for (z = 0; z <= 9: z++)
               {
                    if (b == R1[z][1])
                    {
                         rd = R1[z][2];
                    }
                    if (c == R2[z][1])
                    {
                         rn = R2[z][2];
                    }
                    if (d == R3[z][1])
                    {
                         rm = R3[z][2];
                         i = "0";
                         i_set = true;
                         shamt5 = "0";
                         sh = "0";
                    }
                    if (f == R4[z][1])
                    {
                         rs = R4[z][2];
                    }
               }
          }
          if (i_set == false)
          {
               i = "1";
                    
               //check for # symbol then erase it and set imm8
               lb = d.at(0);
		
               if (lb = "#")
               {
                    d.erase(0);
                    rot = "0000";
			
                    imm8 = std::string binary = std::bitset<8>(lb).to_string();
               } 
          }
          
          for (z = 0; z <= 3; z++)
          {
               if (e == ST[z][1])
               {
                    sh = ST[z][2];
                    z = 3;
               }
          }          
      
          cout << "The final instruction is: " << endl;
	
          //Determine and display final instruction
          if (op == "00")
          {
               if (i == "1")
               {
                    cout << cond << op << i << cmd << s << rn << rd << rot << imm8 << endl;
               }
               else if (i == "0")
               {
                    if ( rs != "0000")
                    {
                         cout << cond << op << i << cmd << s << rn << rd << rs << "0" << sh << "1" << rm << endl;
                    }
                    else
                    {
                         cout << cond << op << i << cmd << s << rn << rd << shamt5 << sh << "0" << rm << endl;
                    }
               }
          }
          else if (op == "01")
          {
               if (i == "1")
               {
                    cout << cond << op << i << p << u << b << w << l << rn << rd << shamt << sh << "0" << rm << endl;
               }
               else if (i == "0")
               {
                    cout << cond << op << i << p << u << b << w << l << rn << rd << imm12 << endl;
               } 
          }
          else if (op == "10")
          {
               cout << cond << op << "1" << il << imm24 << endl;
          }
	}
     
    return 0;
}