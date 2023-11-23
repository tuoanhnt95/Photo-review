<template>
  <div class="login">
    <h1>Login</h1>
    <form @submit="login">
      <label for="email">Email:</label>
      <input type="email" id="email" v-model="email" required>
      <label for="password">Password:</label>
      <input type="password" id="password" v-model="password" required>
      <div>Forgot your password?</div>
      <button type="submit">Login</button>
      <button @click="signUp" class="mt-2">Sign up</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const email = ref('');
const password = ref('');

function login () {
  // Perform login logic here
  console.log('Logging in...');
  // Avoid SQL injection, check input
  // send to server
  // if success, redirect to home page
  // else, show error message
};

function signUp () {
// Perform sign up logic here
console.log('Signing up...');
}
</script>

<style scoped>
.login {
  max-width: 400px;
  margin: 0 auto;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

h1 {
  text-align: center;
}

form {
  display: flex;
  flex-direction: column;
}

label {
  margin-bottom: 10px;
}

input {
  padding: 10px;
  margin-bottom: 20px;
}

button {
  padding: 10px;
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>
