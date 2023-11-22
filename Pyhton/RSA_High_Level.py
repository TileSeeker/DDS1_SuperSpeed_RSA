import math

def blakley(a: int, b: int, n, debug:bool=False):
    """
    Computes a*b mod n
    """
    R = 0
    k = math.ceil(math.log2(a))
    if debug:
        print("a=",a, "b=", b, "n=", n, "k=", k)
    for i in range(0, k):

        R = 2*R + (((a >> (k-1-i)) & (1)) * b)
        if R >= n:
            R = R - n
        if R >= n:
            R = R - n
        if(R >= n):         # If R > n after two iterations encryption will not work, hence take modulo. This is because prime numbers p,q are small. In reality these are huge, and generally R < n
            R = R % n
    return R

#Binary Method
def binary_method(M, e, n, debug:bool=False):
    """
    Computes: C = M**e mod(n)
    """
    e_str = bin(e)[2:]
    #print(e_str)
    if (e_str[0] == '1'):
        C = M
    else:
        C = 1
    for i in e_str[1:]:

        C = blakley(C, C, n)
        if (i == '1'):
            C = blakley(M, C, n)
        if debug:
            print(f"C:{hex(C)} \t (i:{i}")
    return C

if __name__ == "__main__":
    M = 0x0000000011111111222222223333333344444444555555556666666677777777
    n = 0x99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d
    e = 0x0000000000000000000000000000000000000000000000000000000000010001
    d = 0x0cea1651ef44be1f1f1476b7539bed10d73e3aac782bd9999a1e5a790932bfe9

    C = binary_method(M, e, n)
    M_out = binary_method(C, d, n)


    if M == M_out:
        print("HL Implementation Successful")
    else:
        print("Error")
    print(hex(M))
    print(hex(M_out))