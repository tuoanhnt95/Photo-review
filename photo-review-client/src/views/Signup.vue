<template>
  <div class="signup">
    <h1>Signup</h1>
    <form @submit="handleSubmit">
      <label for="email">Email:</label>
      <input type="email" id="email" v-model="email" required class="text-black border">
      <label for="password">Password
        <span v-if="password.length === 0" class="text-red-500">(minimum 6 characters)</span>
        <span v-else-if="password.length < 6" class="text-red-500">({{ 6 - password.length }} more)</span>
      </label>
      <input type="password" id="password" v-model="password" required class="text-black border">
      <label for="confirmPassword">Confirm Password
        <span v-if="password.length === password2.length" class="text-red-500">
          {{ password !== password2 ? '(passwords do not match)' : '(matched)' }}
        </span>
      </label>
      <input type="password" id="confirmPassword" v-model="password2" required class="text-black border">
      <button type="submit">Sign Up</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import axios from 'axios';
import router from '@/router';

const email = ref('');
const password = ref('');
const password2 = ref('');

const validToSubmit = computed (() => {
  return password.value === password2.value && password.value.length >= 6;
});

const handleSubmit = async (event: Event) => {
  event.preventDefault();

  if (password.value.length < 6) {
    alert('Password must be at least 6 characters');
    return;
  }

  if (password.value !== password2.value) {
    alert('Passwords do not match');
    return;
  }

  try {
    await axios.post('http://localhost:3000/users', {
      user: {
        email: email.value,
        password: password.value
      }
    });

    alert('Registration successful! Redirecting to login page...');
    router.push({ name: 'Login' });
  } catch (error) {
    alert('Registration failed. Please try again.');
    console.error('Registration failed:', error);
    // Handle error response here
  }
};
</script>

<style scoped>
.signup {
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
