<template>
  <div class="signup">
    <h1>Signup</h1>
    <form @submit="handleSubmit">
      <label for="email">Email:</label>
      <input type="email" id="email" v-model="email" required class="text-black border">
      <label for="password">Password:</label>
      <input type="password" id="password" v-model="password" required class="text-black border">
      <label for="confirmPassword">Confirm Password:</label>
      <input type="password" id="confirmPassword" v-model="password2" required class="text-black border">
      <button type="submit">Sign Up</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';

const email = ref('');
const password = ref('');
const password2 = ref('');

const handleSubmit = async (event: Event) => {
  event.preventDefault();

  if (password.value !== password2.value) {
    alert('Passwords do not match');
    return;
  }

  try {
    const response = await axios.post('http://localhost:3000/users', {
      user: {
        email: email.value,
        password: password.value
      }
      // email: email.value,
      // password: password.value
    });

    console.log('Registration successful:', response.data);
    // Handle success response here
    // redirect to login page
  } catch (error) {
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
