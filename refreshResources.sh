cd "Sources/LetSee/Core/Website";
echo 'cloning git'
git clone https://github.com/farshadjahanmanesh/letsee-webapplication;
cd letsee-webapplication;
echo 'installing packages...'
npm install;
echo 'building...'
npm run build;
echo 'removing old files...'
rm -R ../build;
echo 'adding new files...'
cp -R ./build ../;
echo 'cleaning up...'
cd ..;
rm -rf ./letsee-webapplication;
echo 'refreshing resources was successfull.'