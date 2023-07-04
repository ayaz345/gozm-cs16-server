def build_ip_list(ip_pool):
    # get begin end end of the pool
    if isinstance(ip_pool, str):
        ip_first, ip_last = ip_pool.split(" ", 1)[0], ip_pool.split(" ")[-1]
    else:
        raise

    # get octet that changed
    index = 3
    octet_in_ip_first, octet_in_ip_last = 0, 255        # default values
    octets_of_ip_first = ip_first.split(".")
    octets_of_ip_last = ip_last.split(".")
    for octet_in_ip_first, octet_in_ip_last in zip(octets_of_ip_first, octets_of_ip_last):
        if eval(octet_in_ip_first) is not eval(octet_in_ip_last):
            index = octets_of_ip_first.index(octet_in_ip_first)
            break

    with open("temp_crap.txt", "w") as f:
        begin, end = eval(octet_in_ip_first), eval(octet_in_ip_last) + 1
        for entry in range(begin, end):
            octets_of_ip_first[index] = str(entry)
            if index is not 4:
                for octet in range(index + 1, 4):
                    octets_of_ip_first[octet] = str(0)
            line = "addip 0.0 " + ".".join(octets_of_ip_first) + "\n"
            f.write(line)

def main():
    build_ip_list('139.223.0.0 - 139.255.255.255')

if __name__ == '__main__':
    main()