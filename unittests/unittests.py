from unittest import TestCase
from framework import AssemblyTest, print_coverage

class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_one(self):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_negative_two(self):
        # same as test_zero, but with input -2
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -2)
        t.call("abs")
        t.check_scalar("a0", 2)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute()

    def test_zero_length(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", 0)
        # call the relu function
        t.call("relu")
        #check for the appropriate error code
        t.check_scalar("a1", 78)
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute(78)

    def test_incorrect_length(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the INCORRECT length of our array
        t.input_scalar("a1", -1)
        # call the relu function
        t.call("relu")
        # check that the array0 was NOT changed
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # check for the appropriate error code
        t.check_scalar("a1", 78)
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute(78)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", 9)
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 8)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_zero_length(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", 0)
        # call the argmax function
        t.call("argmax")
        # check for the appropriate error code
        t.check_scalar("a1", 77)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute(77)

    def test_multiple_max(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([-10, 9, 1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", 11)
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 1)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_0_is_max(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, -9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", 12)
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 0)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_last_is_max(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, 9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", 12)
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 11)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def test_incorrect_length(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([])
        array1 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, 9])
        # load addresses of the array into registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # set a2 to the length of the arrays
        t.input_scalar("a2", -1)
        # set a3 to the stride of vector 1
        t.input_scalar("a3", 1)
        # set a4 to the stride of vector 2
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        # generate the `assembly/TestDot_test_simple.s` file and run it through venus
        t.execute(75)

    def test_incorrect_stride1(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, 9])
        array1 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, 9])
        # load addresses of the array into registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # set a2 to the length of the arrays
        t.input_scalar("a2", 12)
        # set a3 to the stride of vector 1
        t.input_scalar("a3", 0)
        # set a4 to the stride of vector 2
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        # generate the `assembly/TestDot_test_simple.s` file and run it through venus
        t.execute(76)

    def test_incorrect_stride2(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, 9])
        array1 = t.array([0, -10, -9, -1, -2, -3, -4, -5, -6, -7, -8, 9])
        # load addresses of the array into registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # set a2 to the length of the arrays
        t.input_scalar("a2", 12)
        # set a3 to the stride of vector 1
        t.input_scalar("a3", 2)
        # set a4 to the stride of vector 2
        t.input_scalar("a4", -1)
        # call the `dot` function
        t.call("dot")
        # generate the `assembly/TestDot_test_simple.s` file and run it through venus
        t.execute(76)

    def test_simple(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([0, -10, -9, -1, -2, -3, -4, +5, -6, -7, -8, 9])
        array1 = t.array([0, -10, -9, -1, -2, +3, -4, -5, -6, -7, -8, 9])
        # load addresses of the array into registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # set a2 to the length of the arrays
        t.input_scalar("a2", 12)
        # set a3 to the stride of vector 1
        t.input_scalar("a3", 1)
        # set a4 to the stride of vector 2
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        # generate the `assembly/TestDot_test_simple.s` file and run it through venus
        t.execute()
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 398)

    def test_multiple_stride(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        array1 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        # load addresses of the array into registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # set a2 to the length of the arrays
        t.input_scalar("a2", 3)
        # set a3 to the stride of vector 1
        t.input_scalar("a3", 1)
        # set a4 to the stride of vector 2
        t.input_scalar("a4", 2)
        # call the `dot` function
        t.call("dot")
        # generate the `assembly/TestDot_test_simple.s` file and run it through venus
        t.execute()
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 22)

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):

    def do_matmul(self, m0, m0_rows, m0_cols, m1, m1_rows, m1_cols, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        # we need to include (aka import) the dot.s file since it is used by matmul.s
        t.include("dot.s")

        # create arrays for the arguments and to store the result
        array0 = t.array(m0)
        array1 = t.array(m1)
        array_out = t.array([0] * len(result))

        # load address of input matrices and set their dimensions
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_rows)
        t.input_scalar("a2", m0_cols)

        t.input_array("a3", array1)
        t.input_scalar("a4", m1_rows)
        t.input_scalar("a5", m1_cols)

        # load address of output array
        t.input_array("a6", array_out)

        # call the matmul function
        t.call("matmul")

        # check the content of the output array
        t.check_array(array_out, result)

        # generate the assembly file and run it through venus, we expect the simulation to exit with code `code`
        t.execute(code=code)

    def test_mismatch_dims(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 4,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150], 74
        )

    def test_incorrect_dims1(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 0, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150], 73
        )

        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 2,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 0,
            [30, 36, 42, 66, 81, 96, 102, 126, 150], 73
        )

    def test_incorrect_dims0(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 0, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 0, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150], 72
        )

        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 0,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 0,
            [30, 36, 42, 66, 81, 96, 102, 126, 150], 72
        )

    def test_simple(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150]
        )

    def test_3by3(self):
        self.do_matmul(
            [1, 2, 3, -3, -2, -1, -1, 22, 243], 3, 3,
            [456, 500, -6, 86, -5, 4, 0, 6, 5], 3, 3,
            [628, 508, 17, -1540, -1496, 5, 1436, 848, 1309]
        )

    def test_1by3_3by1(self):
        self.do_matmul(
            [1, 2, 3], 1, 3,
            [456, 500, -6], 3, 1,
            [1438]
        )

    def test_1by1_1by5(self):
        self.do_matmul(
            [2], 1, 1,
            [456, 500, -6, 40, 65], 1, 5,
            [912, 1000, -12, 80, 130]
        )

    def test_1by1_1by1(self):
        self.do_matmul(
            [1], 1, 1,
            [-2065], 1, 1,
            [-2065]
        )

    def test_1by1_1by1_zero(self):
        self.do_matmul(
            [1], 1, 1,
            [-0], 1, 1,
            [-0]
        )

    def test_8by2_2by8_zero(self):
        self.do_matmul(
            [1, 2, 2, 1, 5, 4, 4, 5, 2, 3, 5, 6, 6, 5, 4, 6], 8, 2,
            [4, 5, 6, 5, -9, -90, 0, 4110, 4, 6, 5, 0, 8, 10, 0, 2200], 2, 8,
            [12, 17, 16, 5, 7, -70, 0, 8510, 12, 16, 17, 10, -10, -170, 0, 10420,
             36, 49, 50, 25, -13, -410, 0, 29350, 36, 50, 49, 20, 4, -310, 0, 27440,
             20, 28, 27, 10, 6, -150, 0, 14820, 44, 61, 60, 25, 3, -390, 0, 33750,
             44, 60, 61, 30, -14, -490, 0, 35660, 40, 56, 54, 20, 12, -300, 0, 29640]
        )

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

    def do_read_matrix(self, fail='', code=0, file_path="", result=[]):
        t = AssemblyTest(self, "read_matrix.s")
        # load address to the name of the input file into register a0
        t.input_read_filename("a0", file_path)

        # allocate space to hold the rows and cols output parameters
        rows = t.array([-1])
        cols = t.array([-1])

        # load the addresses to the output parameters into the argument registers
        t.input_array("a1", rows)
        t.input_array("a2", cols)

        # call the read_matrix function
        t.call("read_matrix")

        # check the output from the function
        t.check_array_pointer("a0", result)

        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)

    def test_simple(self):
        self.do_read_matrix('', 0, "inputs/test_read_matrix/test_input.bin", [1, 2, 3, 4, 5, 6, 7, 8, 9])

    def test_fopen_error(self):
        self.do_read_matrix('fopen', 90, "inputs/test_read_matrix/test_input.bin", [1, 2, 3, 4, 5, 6, 7, 8, 9])

    def test_malloc_error(self):
        self.do_read_matrix('malloc', 88, "inputs/test_read_matrix/test_input.bin", [1, 2, 3, 4, 5, 6, 7, 8, 9])

    def test_fread_error(self):
        self.do_read_matrix('fread', 91, "inputs/test_read_matrix/test_input.bin", [1, 2, 3, 4, 5, 6, 7, 8, 9])

    def test_fclose_file(self):
        self.do_read_matrix('fclose', 92, "inputs/test_read_matrix/test_input.bin", [1, 2, 3, 4, 5, 6, 7, 8, 9])

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, fail='', code=0, outpath='', refpath='', arr=[], rows=-1, cols=-1):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/student.bin" if outpath == '' else outpath
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        # load input array and other arguments
        input_arr = [1, 2, 3, 4, 5, 6, 7, 8, 9] if arr == [] else arr
        t.input_array("a1", t.array(input_arr))
        input_rows = 3 if rows == -1 else rows
        input_cols = 3 if cols == -1 else cols
        t.input_scalar("a2", input_rows)
        t.input_scalar("a3", input_cols)

        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        # compare the output file against the reference
        reffile = "outputs/test_write_matrix/reference.bin" if refpath == '' else refpath
        if (code == 0):
            t.check_file_output(outfile, reffile)

    def test_simple(self):
        self.do_write_matrix()

    def test_fopen_error(self):
        self.do_write_matrix("fopen", 93)

    def test_fwrite_error(self):
        self.do_write_matrix("fwrite", 94)

    def test_fclose_error(self):
        self.do_write_matrix("fclose", 95)

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        return t

    def test_simple0_input0(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        t.input_scalar("a2", 0)
        # call classify function
        t.call("classify")
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args)
        # compare the output file and reference
        t.check_file_output(out_file, ref_file)
        # compare the classification output with `check_stdout`
        t.check_stdout("2")

    def test_incorrect_args(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", "WRONG_ARG", out_file]
        t.input_scalar("a2", 0)
        # call classify function
        t.call("classify")
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args,code=89)

    def test_malloc_error(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        t.input_scalar("a2", 0)
        # call classify function
        t.call("classify")
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args,fail="malloc", code=88)

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label, input_id='input0', flag=False):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/{input_id}.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        if flag:
            t.check_file_output(args[-1], reference)

    def test00(self):
        self.run_main("inputs/simple0/bin", "00", "2", "input0", flag=True)

    def test01(self):
        self.run_main("inputs/simple0/bin", "01", "2", "input1", flag=True)

    def test02(self):
        self.run_main("inputs/simple0/bin", "02", "2", "input2", flag=True)

    def test10(self):
        self.run_main("inputs/simple1/bin", "10", "1", 'input0', flag=True)

    def test11(self):
        self.run_main("inputs/simple1/bin", "11", "4", "input1", flag=True)

    def test12(self):
        self.run_main("inputs/simple1/bin", "12", "1", "input2", flag=True)

    def test20(self):
        self.run_main("inputs/simple2/bin", "20", "7", 'input0', flag=True)

    def test21(self):
        self.run_main("inputs/simple2/bin", "21", "4", "input1", flag=True)

    def test22(self):
        self.run_main("inputs/simple2/bin", "22", "10", "input2", flag=True)

    def test_mnist0(self):
        self.run_main("inputs/mnist/bin", "mnist0", "6", "mnist_input0")

    def test_mnist1(self):
        self.run_main("inputs/mnist/bin", "mnist1", "9", "mnist_input1")

    # def test_mnist2(self):
    #     self.run_main("inputs/mnist/bin", "mnist2", "7", "mnist_input2")

    def test_mnist3(self):
        self.run_main("inputs/mnist/bin", "mnist3", "2", "mnist_input3")

    def test_mnist4(self):
        self.run_main("inputs/mnist/bin", "mnist4", "9", "mnist_input4")

    def test_mnist5(self):
        self.run_main("inputs/mnist/bin", "mnist5", "4", "mnist_input5")

    def test_mnist6(self):
        self.run_main("inputs/mnist/bin", "mnist6", "4", "mnist_input6")

    # def test_mnist7(self):
    #     self.run_main("inputs/mnist/bin", "mnist7", "2", "mnist_input7")

    def testmnist8(self):
        self.run_main("inputs/mnist/bin", "mnist8", "7", "mnist_input8")
