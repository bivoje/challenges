
# python3 -m unittest -v 
# python3 -m unittest.TestNaturaln2c -v 

from sol import *

import unittest
from random import *
import sys

sys.setrecursionlimit(4000)

class TestNatural_n2c(unittest.TestCase):

  def test_n2c_0(self):
    self.assertEqual(c2n(n2c(0)), 0)
    self.assertEqual(n2c(c2n(zero))(zero, self), self)

  def test_n2c_small(self):
    for _ in range(100):
      val = randint(0, 100000)
      self.assertEqual(c2n(n2c(val)), val)

  def test_n2c_big(self):
    for _ in range(10):
      val = randint(0, 1000000)
      self.assertEqual(c2n(n2c(val)), val)

class TestNatural_add(unittest.TestCase):

  def test_add_manual(self):
    self.assertEqual(c2n(add(zero,    zero   )), 0)
    self.assertEqual(c2n(add(s(zero), zero   )), 1)
    self.assertEqual(c2n(add(zero,    s(zero))), 1)
    self.assertEqual(c2n(add(s(zero), s(zero))), 2)

  def test_add_0_left(self):
    for _ in range(100):
      b = randint(0, 100000)
      self.assertEqual(c2n(add(zero,n2c(b))), b)

  def test_add_0_right(self):
    for _ in range(100):
      a = randint(0, 100000)
      self.assertEqual(c2n(add(n2c(a),zero)), a)

  def test_add_comm(self):
    for _ in range(100):
      a = randint(0, 10000)
      b = randint(0, 10000)
      aa = n2c(a)
      bb = n2c(b)
      self.assertEqual(c2n(add(aa,bb)),c2n(add(bb,aa)))

  def test_add_small(self):
    for _ in range(100):
      a = randint(0, 10000)
      b = randint(0, 10000)
      self.assertEqual(c2n(add(n2c(a),n2c(b))), a+b)

  def test_add_big(self):
    for _ in range(10):
      a = randint(0, 100000)
      b = randint(0, 100000)
      self.assertEqual(c2n(add(n2c(a),n2c(b))), a+b)

class TestNatural_mult(unittest.TestCase):

  def test_mult_manual(self):
    self.assertEqual(c2n(mult(zero,    zero   )), 0)
    self.assertEqual(c2n(mult(s(zero), zero   )), 0)
    self.assertEqual(c2n(mult(zero,    s(zero))), 0)
    self.assertEqual(c2n(mult(s(zero), s(zero))), 1)

  def test_mult_0_left(self):
    for _ in range(100):
      b = randint(0, 100000)
      self.assertEqual(c2n(mult(zero,n2c(b))), 0)

  def test_mult_0_right(self):
    for _ in range(100):
      a = randint(0, 100000)
      self.assertEqual(c2n(mult(n2c(a),zero)), 0)

  def test_mult_comm(self):
    for _ in range(100):
      a = randint(0, 1000)
      b = randint(0, 1000)
      aa = n2c(a)
      bb = n2c(b)
      self.assertEqual(c2n(mult(aa,bb)),c2n(mult(bb,aa)))

  def test_mult_small(self):
    for _ in range(100):
      a = randint(0, 1000)
      b = randint(0, 1000)
      self.assertEqual(c2n(mult(n2c(a),n2c(b))), a*b)

class TestNatural_exp(unittest.TestCase):

  def test_exp_manual(self):
    self.assertEqual(c2n(exp(zero,    zero   )), 1)
    self.assertEqual(c2n(exp(s(zero), zero   )), 1)
    self.assertEqual(c2n(exp(zero,    s(zero))), 0)
    self.assertEqual(c2n(exp(s(zero), s(zero))), 1)

  def test_exp_0_left(self):
    for _ in range(10):
      b = randint(0, 100000)
      self.assertEqual(c2n(exp(zero,n2c(b))), 0)

  def test_exp_0_right(self):
    for _ in range(100):
      a = randint(0, 100000)
      self.assertEqual(c2n(exp(n2c(a),zero)), 1)

  def test_exp_1_left(self):
    for _ in range(10):
      b = randint(0, 1000)
      self.assertEqual(c2n(exp(s(zero),n2c(b))), 1)

  def test_exp_1_right(self):
    for _ in range(100):
      a = randint(0, 100000)
      self.assertEqual(c2n(exp(n2c(a),s(zero))), a)

  def test_exp_small(self):
    for a in range(14):
      b = 14 - a
      self.assertEqual(c2n(exp(n2c(a),n2c(b))), a**b)
