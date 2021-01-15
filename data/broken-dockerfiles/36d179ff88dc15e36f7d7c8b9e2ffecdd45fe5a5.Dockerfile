# Base image
FROM iojs

# Set the working dir
WORKDIR /app

# Copy app files
COPY package.json /app/
COPY dist /app/dist/

# Install deps
RUN npm install --quiet --production

# Start command
CMD ["npm", "start"]

# Expose port
EXPOSE 9090
